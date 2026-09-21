<?php
require_once 'config.php';

$user_id = getAuthUser();
$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];
$salesTable = tbl('sales');
$installmentsTable = tbl('installments');
$customersTable = tbl('customers');
$inventoryTable = tbl('inventory');
$movementsTable = tbl('inventory_movements');
$productsTable = tbl('products');

try {
    switch ($method) {
        
        case 'POST':
            $input = getInput();
            
            $required = ['customer_id', 'product_id', 'product_name', 'total_price', 
                        'installments_count', 'installment_type', 'currency', 'sale_date'];
            foreach ($required as $field) {
                if (!isset($input[$field]) || $input[$field] === '') {
                    jsonResponse(false, null, "الحقل {$field} مطلوب");
                }
            }
            
            $quantity = filter_var($input['quantity'] ?? 1, FILTER_VALIDATE_INT);
            $downPayment = $input['down_payment'] ?? 0;
            $totalPrice = $input['total_price'];
            $installmentsCount = filter_var($input['installments_count'] ?? null, FILTER_VALIDATE_INT);

            if ($quantity === false || $quantity < 1 || $quantity > 100000) {
                http_response_code(400);
                jsonResponse(false, null, 'الكمية غير صالحة');
            }
            if (!is_numeric($totalPrice) || (float)$totalPrice <= 0) {
                http_response_code(400);
                jsonResponse(false, null, 'السعر الكلي غير صالح');
            }
            if (!is_numeric($downPayment) || (float)$downPayment < 0) {
                http_response_code(400);
                jsonResponse(false, null, 'الدفعة المقدمة غير صالحة');
            }
            if ($installmentsCount === false || $installmentsCount < 1 || $installmentsCount > 120) {
                http_response_code(400);
                jsonResponse(false, null, 'عدد الأقساط يجب أن يكون بين 1 و120');
            }

            $totalPrice = round((float)$totalPrice, 2);
            $downPayment = round((float)$downPayment, 2);
            $remaining = round($totalPrice - $downPayment, 2);
            if ($downPayment >= $totalPrice || $remaining <= 0) {
                http_response_code(400);
                jsonResponse(false, null, 'الدفعة المقدمة يجب أن تكون أقل من السعر الكلي');
            }

            $allowedInstallmentTypes = ['weekly', 'monthly'];
            if (!in_array($input['installment_type'], $allowedInstallmentTypes, true)) {
                http_response_code(400);
                jsonResponse(false, null, 'نوع التقسيط غير صالح');
            }
            $allowedCurrencies = ['USD', 'LOCAL'];
            if (!in_array($input['currency'], $allowedCurrencies, true)) {
                http_response_code(400);
                jsonResponse(false, null, 'العملة غير صالحة');
            }
            $saleDate = DateTime::createFromFormat('Y-m-d', (string)$input['sale_date']);
            if (!$saleDate || $saleDate->format('Y-m-d') !== $input['sale_date']) {
                http_response_code(400);
                jsonResponse(false, null, 'تاريخ البيع غير صالح');
            }
            $installmentValue = round($remaining / $installmentsCount, 2);
            $productId = intval($input['product_id']);
            $customerId = intval($input['customer_id']);
            
            // التأكد أن المشتري يخص المستخدم الحالي
            $stmt = $db->prepare("SELECT id FROM `{$customersTable}` WHERE id = ? AND user_id = ?");
            $stmt->execute([$customerId, $user_id]);
            if (!$stmt->fetch()) {
                http_response_code(404);
                jsonResponse(false, null, 'المشتري غير موجود أو لا يخص حسابك');
            }
            
            // جلب سعر الشراء الحالي من المادة والتأكد أنها تخص المستخدم الحالي
            $stmt = $db->prepare("SELECT cost_price FROM `{$productsTable}` WHERE id = ? AND user_id = ?");
            $stmt->execute([$productId, $user_id]);
            $product = $stmt->fetch();
            if (!$product) {
                http_response_code(404);
                jsonResponse(false, null, 'المادة غير موجودة أو لا تخص حسابك');
            }
            $costPriceAtSale = floatval($product['cost_price']);
            
            $db->beginTransaction();
            
            $stmt = $db->prepare("INSERT INTO `{$salesTable}` 
                (user_id, customer_id, product_id, product_name, quantity, cost_price_at_sale, total_price, down_payment, remaining,
                 installment_value, installments_count, installment_type, currency, sale_date, notes)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            
            $stmt->execute([
                $user_id,
                $customerId,
                $productId,
                $input['product_name'],
                $quantity,
                $costPriceAtSale,
                $totalPrice,
                $downPayment,
                $remaining,
                $installmentValue,
                $installmentsCount,
                $input['installment_type'],
                $input['currency'],
                $input['sale_date'],
                $input['notes'] ?? null
            ]);
            
            $saleId = $db->lastInsertId();
            
            // خصم من المخزن إذا كان مُفعّلاً
            $stockMessage = '';
            $stmt = $db->prepare("SELECT * FROM `{$inventoryTable}` WHERE product_id = ? AND user_id = ? FOR UPDATE");
            $stmt->execute([$productId, $user_id]);
            $inventory = $stmt->fetch();
            
            if ($inventory) {
                $newQuantity = $inventory['quantity'] - $quantity;
                
                $stmt = $db->prepare("UPDATE `{$inventoryTable}` 
                                      SET quantity = ? 
                                      WHERE product_id = ? AND user_id = ?");
                $stmt->execute([$newQuantity, $productId, $user_id]);
                
                $stmt = $db->prepare("INSERT INTO `{$movementsTable}` 
                                      (user_id, product_id, movement_type, quantity, sale_id, notes)
                                      VALUES (?, ?, 'subtract', ?, ?, ?)");
                $stmt->execute([
                    $user_id,
                    $productId,
                    $quantity,
                    $saleId,
                    "بيع رقم {$saleId}"
                ]);
                
                if ($newQuantity < 0) {
                    $stockMessage = " ⚠️ تنبيه: المخزون أصبح بالسالب ({$newQuantity})";
                } elseif ($newQuantity == 0) {
                    $stockMessage = " ⚠️ تنبيه: نفدت الكمية من المخزن";
                } elseif ($newQuantity <= $inventory['low_stock_threshold']) {
                    $stockMessage = " ⚠️ تنبيه: الكمية المتبقية ({$newQuantity}) منخفضة";
                }
            }
            
            $startDate = clone $saleDate;
            $interval = $input['installment_type'] === 'weekly' ? 'P7D' : 'P1M';
            
            $stmtInst = $db->prepare("INSERT INTO `{$installmentsTable}` 
                (user_id, sale_id, installment_number, amount, due_date) 
                VALUES (?, ?, ?, ?, ?)");
            
            for ($i = 1; $i <= $installmentsCount; $i++) {
                $dueDate = clone $startDate;
                $dueDate->add(new DateInterval($interval));
                $startDate = clone $dueDate;
                
                $amount = ($i === $installmentsCount) 
                    ? $remaining - ($installmentValue * ($installmentsCount - 1))
                    : $installmentValue;
                
                $stmtInst->execute([$user_id, $saleId, $i, $amount, $dueDate->format('Y-m-d')]);
            }
            
            $db->commit();
            
            jsonResponse(true, [
                'sale_id' => $saleId,
                'installment_value' => $installmentValue,
                'remaining' => $remaining,
                'stock_warning' => $stockMessage
            ], 'تم تسجيل عملية البيع بنجاح' . $stockMessage);
            break;
        
        case 'GET':
            if (isset($_GET['id'])) {
                $stmt = $db->prepare("
                    SELECT s.*, c.name as customer_name, c.phone as customer_phone
                    FROM `{$salesTable}` s
                    INNER JOIN `{$customersTable}` c ON s.customer_id = c.id
                    WHERE s.id = ? AND s.user_id = ?
                ");
                $stmt->execute([$_GET['id'], $user_id]);
                $sale = $stmt->fetch();
                
                if ($sale) {
                    $stmt = $db->prepare("SELECT * FROM `{$installmentsTable}` 
                                          WHERE sale_id = ? AND user_id = ? ORDER BY installment_number");
                    $stmt->execute([$_GET['id'], $user_id]);
                    $sale['installments'] = $stmt->fetchAll();
                }
                
                jsonResponse($sale !== false, $sale);
            } else {
                $stmt = $db->prepare("
                    SELECT s.*, c.name as customer_name, c.phone as customer_phone
                    FROM `{$salesTable}` s
                    INNER JOIN `{$customersTable}` c ON s.customer_id = c.id
                    WHERE s.user_id = ?
                    ORDER BY s.created_at DESC
                ");
                $stmt->execute([$user_id]);
                jsonResponse(true, $stmt->fetchAll());
            }
            break;
        
        case 'DELETE':
            $id = $_GET['id'] ?? null;
            if (!$id) jsonResponse(false, null, 'المعرف مطلوب');
            
            $db->beginTransaction();
            
            // استرجاع الكمية للمخزن (فقط إذا كان البيع يخص المستخدم الحالي)
            $stmt = $db->prepare("SELECT product_id, quantity FROM `{$salesTable}` WHERE id = ? AND user_id = ?");
            $stmt->execute([$id, $user_id]);
            $sale = $stmt->fetch();
            
            if (!$sale) {
                $db->rollBack();
                http_response_code(404);
                jsonResponse(false, null, 'عملية البيع غير موجودة أو لا تخص حسابك');
            }
            
            $returnMessage = '';
            $stmt = $db->prepare("SELECT id FROM `{$inventoryTable}` WHERE product_id = ? AND user_id = ?");
            $stmt->execute([$sale['product_id'], $user_id]);
            $hasInventory = $stmt->fetch();
            
            if ($hasInventory) {
                $stmt = $db->prepare("UPDATE `{$inventoryTable}` 
                                      SET quantity = quantity + ? 
                                      WHERE product_id = ? AND user_id = ?");
                $stmt->execute([$sale['quantity'], $sale['product_id'], $user_id]);
                
                $stmt = $db->prepare("INSERT INTO `{$movementsTable}` 
                                      (user_id, product_id, movement_type, quantity, sale_id, notes)
                                      VALUES (?, ?, 'return', ?, ?, ?)");
                $stmt->execute([
                    $user_id,
                    $sale['product_id'],
                    $sale['quantity'],
                    $id,
                    "حذف بيع رقم {$id} - استرجاع للمخزن"
                ]);
                
                $returnMessage = " (تم استرجاع {$sale['quantity']} للمخزن)";
            }
            
            $stmt = $db->prepare("DELETE FROM `{$salesTable}` WHERE id = ? AND user_id = ?");
            $stmt->execute([$id, $user_id]);
            
            $db->commit();
            
            jsonResponse(true, null, 'تم حذف عملية البيع' . $returnMessage);
            break;
        
        default:
            http_response_code(405);
            jsonResponse(false, null, 'الطريقة غير مدعومة');
    }
} catch (Exception $e) {
    if ($db->inTransaction()) $db->rollBack();
    error_log('sales.php: ' . $e->getMessage());
    http_response_code(500);
    jsonResponse(false, null, 'حدث خطأ في معالجة عملية البيع، يرجى المحاولة مرة أخرى');
}

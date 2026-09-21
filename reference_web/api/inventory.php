<?php
require_once 'config.php';

$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];
$inventoryTable = tbl('inventory');
$movementsTable = tbl('inventory_movements');
$productsTable = tbl('products');

// جلب رقم المستخدم المسجل حالياً عبر التوكن
$user_id = getAuthUser();

try {
    switch ($method) {
        
        case 'GET':
            // ============ جلب كمية مادة واحدة ============
            if (isset($_GET['product_id'])) {
                $stmt = $db->prepare("SELECT i.*, p.name as product_name 
                                      FROM `{$inventoryTable}` i
                                      INNER JOIN `{$productsTable}` p ON i.product_id = p.id
                                      WHERE i.product_id = ? AND i.user_id = ?");
                $stmt->execute([$_GET['product_id'], $user_id]);
                $inv = $stmt->fetch();
                jsonResponse(true, $inv ?: null);
                break;
            }
            
            // ============ جلب حركات مادة ============
            if (isset($_GET['movements'])) {
                $stmt = $db->prepare("SELECT m.*, p.name as product_name
                                      FROM `{$movementsTable}` m
                                      INNER JOIN `{$productsTable}` p ON m.product_id = p.id
                                      WHERE m.product_id = ? AND m.user_id = ?
                                      ORDER BY m.created_at DESC
                                      LIMIT 50");
                $stmt->execute([$_GET['movements'], $user_id]);
                jsonResponse(true, $stmt->fetchAll());
                break;
            }
            
            // ============ تنبيهات المخزون المنخفض ============
            if (isset($_GET['low_stock'])) {
                $stmt = $db->prepare("SELECT i.*, p.name as product_name, p.price, p.currency
                                      FROM `{$inventoryTable}` i
                                      INNER JOIN `{$productsTable}` p ON i.product_id = p.id
                                      WHERE i.quantity <= i.low_stock_threshold AND i.user_id = ?
                                      ORDER BY i.quantity ASC");
                $stmt->execute([$user_id]);
                jsonResponse(true, $stmt->fetchAll());
                break;
            }
            
            // ============ كل المواد مع المخزون ============
            $stmt = $db->prepare("
                SELECT 
                    p.id as product_id,
                    p.name as product_name,
                    p.price,
                    p.currency,
                    i.id as inventory_id,
                    i.quantity,
                    i.low_stock_threshold,
                    i.notes as inventory_notes,
                    i.updated_at,
                    CASE 
                        WHEN i.id IS NULL THEN 'not_tracked'
                        WHEN i.quantity = 0 THEN 'out_of_stock'
                        WHEN i.quantity <= i.low_stock_threshold THEN 'low_stock'
                        ELSE 'in_stock'
                    END as stock_status
                FROM `{$productsTable}` p
                LEFT JOIN `{$inventoryTable}` i ON p.id = i.product_id
                WHERE p.user_id = ?
                ORDER BY p.name ASC
            ");
            $stmt->execute([$user_id]);
            jsonResponse(true, $stmt->fetchAll());
            break;

        case 'POST':
            $input = getInput();
            
            if (empty($input['product_id'])) {
                jsonResponse(false, null, 'معرف المادة مطلوب');
            }
            
            $productId = intval($input['product_id']);
            $quantity = intval($input['quantity'] ?? 0);
            $threshold = intval($input['low_stock_threshold'] ?? 3);
            $action = $input['action'] ?? 'set'; 
            
            $stmt = $db->prepare("SELECT id FROM `{$productsTable}` WHERE id = ? AND user_id = ?");
            $stmt->execute([$productId, $user_id]);
            if (!$stmt->fetch()) {
                jsonResponse(false, null, 'المادة غير موجودة أو لا تملك صلاحية تعديلها');
            }

            $db->beginTransaction();
            
            $stmt = $db->prepare("SELECT * FROM `{$inventoryTable}` WHERE product_id = ? AND user_id = ?");
            $stmt->execute([$productId, $user_id]);
            $existing = $stmt->fetch();
            
            if ($existing) {
                if ($action === 'add') {
                    $newQuantity = $existing['quantity'] + $quantity;
                    $movementType = 'add';
                    $movementQty = $quantity;
                } else {
                    $newQuantity = $quantity;
                    $movementType = 'adjustment';
                    $movementQty = $quantity - $existing['quantity'];
                }
                
                $stmt = $db->prepare("UPDATE `{$inventoryTable}` 
                                      SET quantity = ?, low_stock_threshold = ?, notes = ?
                                      WHERE product_id = ? AND user_id = ?");
                $stmt->execute([
                    $newQuantity,
                    $threshold,
                    $input['notes'] ?? null,
                    $productId,
                    $user_id
                ]);
            } else {
                $stmt = $db->prepare("INSERT INTO `{$inventoryTable}` 
                                      (product_id, user_id, quantity, low_stock_threshold, notes)
                                      VALUES (?, ?, ?, ?, ?)");
                $stmt->execute([
                    $productId,
                    $user_id,
                    $quantity,
                    $threshold,
                    $input['notes'] ?? null
                ]);
                $newQuantity = $quantity;
                $movementType = 'add';
                $movementQty = $quantity;
            }
            
            if ($movementQty != 0) {
                $stmt = $db->prepare("INSERT INTO `{$movementsTable}` 
                                      (product_id, user_id, movement_type, quantity, notes)
                                      VALUES (?, ?, ?, ?, ?)");
                $stmt->execute([
                    $productId,
                    $user_id,
                    $movementType,
                    abs($movementQty),
                    $input['notes'] ?? 'إضافة كمية للمخزن'
                ]);
            }
            
            $db->commit();
            jsonResponse(true, ['quantity' => $newQuantity], 'تم تحديث المخزن بنجاح ✅');
            break;
        
        case 'PUT':
            $input = getInput();
            if (empty($input['product_id'])) {
                jsonResponse(false, null, 'معرف المادة مطلوب');
            }
            
            $stmt = $db->prepare("UPDATE `{$inventoryTable}` 
                                  SET low_stock_threshold = ?, notes = ?
                                  WHERE product_id = ? AND user_id = ?");
            $stmt->execute([
                $input['low_stock_threshold'] ?? 3,
                $input['notes'] ?? null,
                $input['product_id'],
                $user_id
            ]);
            
            jsonResponse(true, null, 'تم التحديث بنجاح');
            break;
        
        case 'DELETE':
            $productId = $_GET['product_id'] ?? null;
            if (!$productId) {
                jsonResponse(false, null, 'معرف المادة مطلوب');
            }
            
            $stmt = $db->prepare("DELETE FROM `{$inventoryTable}` WHERE product_id = ? AND user_id = ?");
            $stmt->execute([$productId, $user_id]);
            
            jsonResponse(true, null, 'تم إيقاف تتبع المخزن لهذه المادة');
            break;
        
        default:
            http_response_code(405);
            jsonResponse(false, null, 'الطريقة غير مدعومة');
    }
} catch (Exception $e) {
    if ($db->inTransaction()) $db->rollBack();
    http_response_code(500);
    error_log('inventory.php: ' . $e->getMessage());
    jsonResponse(false, null, 'حدث خطأ في معالجة المخزون، يرجى المحاولة مرة أخرى');
}
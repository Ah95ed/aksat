<?php
require_once 'config.php';

$user_id = getAuthUser();
$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];
$table = tbl('customers');
$salesTable = tbl('sales');
$installmentsTable = tbl('installments');

try {
    switch ($method) {
        
        case 'GET':
            // البحث الذكي (autocomplete) - ضمن مشتري المستخدم الحالي فقط
            if (isset($_GET['search'])) {
                $search = '%' . $_GET['search'] . '%';
                $stmt = $db->prepare("SELECT id, name, phone FROM `{$table}` 
                                      WHERE (name LIKE ? OR phone LIKE ?) AND user_id = ?
                                      LIMIT 10");
                $stmt->execute([$search, $search, $user_id]);
                jsonResponse(true, $stmt->fetchAll());
                break;
            }
            
            // تفاصيل مشتري واحد مع كل مبيعاته وأقساطه
            if (isset($_GET['id'])) {
                $stmt = $db->prepare("SELECT * FROM `{$table}` WHERE id = ? AND user_id = ?");
                $stmt->execute([$_GET['id'], $user_id]);
                $customer = $stmt->fetch();
                
                if (!$customer) {
                    http_response_code(404);
                    jsonResponse(false, null, 'المشتري غير موجود');
                }
                
                // جلب المبيعات
                $stmt = $db->prepare("SELECT * FROM `{$salesTable}` 
                                      WHERE customer_id = ? AND user_id = ?
                                      ORDER BY created_at DESC");
                $stmt->execute([$_GET['id'], $user_id]);
                $sales = $stmt->fetchAll();
                
                // جلب أقساط كل عملية بيع
                foreach ($sales as &$sale) {
                    $stmt = $db->prepare("SELECT * FROM `{$installmentsTable}` 
                                          WHERE sale_id = ? AND user_id = ?
                                          ORDER BY installment_number ASC");
                    $stmt->execute([$sale['id'], $user_id]);
                    $sale['installments'] = $stmt->fetchAll();
                    
                    // حساب الإحصائيات
                    $sale['paid_count'] = 0;
                    $sale['late_count'] = 0;
                    $sale['paid_amount'] = 0;
                    
                    foreach ($sale['installments'] as &$inst) {
                        // تحديث حالة المتأخر تلقائياً
                        if ($inst['status'] === 'pending' && strtotime($inst['due_date']) < strtotime(date('Y-m-d'))) {
                            $inst['status'] = 'late';
                            $db->prepare("UPDATE `{$installmentsTable}` SET status = 'late' WHERE id = ? AND user_id = ?")
                               ->execute([$inst['id'], $user_id]);
                        }
                        
                        if ($inst['status'] === 'paid') {
                            $sale['paid_count']++;
                            $sale['paid_amount'] += $inst['amount'];
                        } elseif ($inst['status'] === 'late') {
                            $sale['late_count']++;
                        }
                    }
                }
                
                $customer['sales'] = $sales;
                jsonResponse(true, $customer);
                break;
            }
            
            // جلب كل مشتري المستخدم الحالي مع ملخص
            $stmt = $db->prepare("
                SELECT 
                    c.*,
                    COUNT(DISTINCT s.id) as sales_count,
                    SUM(CASE WHEN s.status = 'active' THEN 1 ELSE 0 END) as active_sales,
                    (SELECT COUNT(*) FROM `{$installmentsTable}` i 
                     INNER JOIN `{$salesTable}` s2 ON i.sale_id = s2.id 
                     WHERE s2.customer_id = c.id AND i.status = 'late' AND i.user_id = ?) as late_count
                FROM `{$table}` c
                LEFT JOIN `{$salesTable}` s ON s.customer_id = c.id AND s.user_id = ?
                WHERE c.user_id = ?
                GROUP BY c.id
                ORDER BY c.created_at DESC
            ");
            $stmt->execute([$user_id, $user_id, $user_id]);
            jsonResponse(true, $stmt->fetchAll());
            break;
        
        case 'POST':
            $input = getInput();
            
            if (empty($input['name']) || empty($input['phone'])) {
                jsonResponse(false, null, 'الاسم ورقم الهاتف مطلوبان');
            }
            
            // التحقق من عدم تكرار الاسم والهاتف لنفس المستخدم
            $stmt = $db->prepare("SELECT id FROM `{$table}` WHERE name = ? AND phone = ? AND user_id = ?");
            $stmt->execute([$input['name'], $input['phone'], $user_id]);
            $existing = $stmt->fetch();
            
            if ($existing) {
                jsonResponse(true, ['id' => $existing['id'], 'existing' => true], 'المشتري موجود مسبقاً');
            }
            
            $stmt = $db->prepare("INSERT INTO `{$table}` (user_id, name, phone, address, notes) 
                                  VALUES (?, ?, ?, ?, ?)");
            $stmt->execute([
                $user_id,
                $input['name'],
                $input['phone'],
                $input['address'] ?? null,
                $input['notes'] ?? null
            ]);
            
            jsonResponse(true, ['id' => $db->lastInsertId(), 'existing' => false], 'تمت إضافة المشتري بنجاح');
            break;
        
        case 'PUT':
            $input = getInput();
            if (empty($input['id'])) {
                jsonResponse(false, null, 'معرف المشتري مطلوب');
            }
            
            // التأكد أن المشتري يخص المستخدم الحالي
            $stmt = $db->prepare("SELECT id FROM `{$table}` WHERE id = ? AND user_id = ?");
            $stmt->execute([$input['id'], $user_id]);
            if (!$stmt->fetch()) {
                http_response_code(404);
                jsonResponse(false, null, 'المشتري غير موجود أو لا تملك صلاحية تعديله');
            }
            
            $stmt = $db->prepare("UPDATE `{$table}` 
                                  SET name = ?, phone = ?, address = ?, notes = ? 
                                  WHERE id = ? AND user_id = ?");
            $stmt->execute([
                $input['name'],
                $input['phone'],
                $input['address'] ?? null,
                $input['notes'] ?? null,
                $input['id'],
                $user_id
            ]);
            
            jsonResponse(true, null, 'تم تحديث بيانات المشتري');
            break;
        
        case 'DELETE':
            $id = $_GET['id'] ?? null;
            if (!$id) {
                jsonResponse(false, null, 'معرف المشتري مطلوب');
            }
            
            // التأكد أن المشتري يخص المستخدم الحالي قبل الحذف
            $stmt = $db->prepare("SELECT id FROM `{$table}` WHERE id = ? AND user_id = ?");
            $stmt->execute([$id, $user_id]);
            if (!$stmt->fetch()) {
                http_response_code(404);
                jsonResponse(false, null, 'المشتري غير موجود أو لا تملك صلاحية حذفه');
            }
            
            $stmt = $db->prepare("DELETE FROM `{$table}` WHERE id = ? AND user_id = ?");
            $stmt->execute([$id, $user_id]);
            
            jsonResponse(true, null, 'تم حذف المشتري');
            break;
        
        default:
            http_response_code(405);
            jsonResponse(false, null, 'الطريقة غير مدعومة');
    }
} catch (PDOException $e) {
    error_log('customers.php: ' . $e->getMessage());
    http_response_code(500);
    jsonResponse(false, null, 'حدث خطأ في معالجة بيانات المشتري، يرجى المحاولة مرة أخرى');
}

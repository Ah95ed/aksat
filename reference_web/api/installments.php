<?php
require_once 'config.php';

$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];
$installmentsTable = tbl('installments');
$salesTable = tbl('sales');
$customersTable = tbl('customers');

// التحقق من التوكن وحالة الاشتراك (نفس الدالة المستخدمة في بقية ملفات الـ API)
$user_id = getAuthUser();

try {
    switch ($method) {
        
        case 'GET':
            $filter = $_GET['filter'] ?? 'all';
            $today = date('Y-m-d');
            
            // تحديث الأقساط المتأخرة تلقائياً (للمستخدم الحالي فقط)
            $stmt = $db->prepare("UPDATE `{$installmentsTable}` 
                                  SET status = 'late' 
                                  WHERE status = 'pending' AND due_date < ? AND user_id = ?");
            $stmt->execute([$today, $user_id]);
            
            $where = 'WHERE i.user_id = ?';
            $params = [$user_id];
            
            switch ($filter) {
                case 'late':
                    $where .= " AND i.status = 'late'";
                    break;
                case 'upcoming_week':
                    $where .= " AND i.status = 'pending' AND i.due_date BETWEEN ? AND ?";
                    array_push($params, $today, date('Y-m-d', strtotime('+7 days')));
                    break;
                case 'upcoming_month':
                    $where .= " AND i.status = 'pending' AND i.due_date BETWEEN ? AND ?";
                    array_push($params, $today, date('Y-m-d', strtotime('+30 days')));
                    break;
                case 'paid':
                    $where .= " AND i.status = 'paid'";
                    break;
            }
            
            $stmt = $db->prepare("
                SELECT i.*, 
                       s.product_name, s.currency, s.customer_id,
                       c.name as customer_name, c.phone as customer_phone
                FROM `{$installmentsTable}` i
                INNER JOIN `{$salesTable}` s ON i.sale_id = s.id
                INNER JOIN `{$customersTable}` c ON s.customer_id = c.id
                {$where}
                ORDER BY i.due_date ASC
            ");
            $stmt->execute($params);
            jsonResponse(true, $stmt->fetchAll());
            break;
        
        case 'PUT':
            $input = getInput();
            
            if (empty($input['id']) || empty($input['action']) || !filter_var($input['id'], FILTER_VALIDATE_INT)) {
                jsonResponse(false, null, 'بيانات ناقصة');
            }
            
            if (!in_array($input['action'], ['pay', 'unpay', 'update_notes'], true)) {
                http_response_code(400);
                jsonResponse(false, null, 'إجراء القسط غير صالح');
            }

            if ($input['action'] === 'pay') {
                $paidDate = $input['paid_date'] ?? date('Y-m-d');
                $paidDateObj = DateTime::createFromFormat('Y-m-d', (string)$paidDate);
                if (!$paidDateObj || $paidDateObj->format('Y-m-d') !== $paidDate) {
                    http_response_code(400);
                    jsonResponse(false, null, 'تاريخ الدفع غير صالح');
                }

                // تسجيل الدفع
                $stmt = $db->prepare("UPDATE `{$installmentsTable}` 
                                      SET status = 'paid', paid_date = ? 
                                      WHERE id = ? AND user_id = ?");
                $stmt->execute([
                    $paidDate,
                    $input['id'],
                    $user_id
                ]);
                
                // التحقق إذا تم دفع جميع الأقساط لتحديث حالة البيع
                $stmt = $db->prepare("SELECT sale_id FROM `{$installmentsTable}` WHERE id = ? AND user_id = ?");
                $stmt->execute([$input['id'], $user_id]);
                $row = $stmt->fetch();
                
                if ($row) {
                    $stmt = $db->prepare("SELECT COUNT(*) as total,
                                                 SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) as paid
                                          FROM `{$installmentsTable}` 
                                          WHERE sale_id = ? AND user_id = ?");
                    $stmt->execute([$row['sale_id'], $user_id]);
                    $counts = $stmt->fetch();
                    
                    if ($counts['total'] == $counts['paid']) {
                        $db->prepare("UPDATE `{$salesTable}` SET status = 'completed' WHERE id = ? AND user_id = ?")
                           ->execute([$row['sale_id'], $user_id]);
                    }
                }
                
                jsonResponse(true, null, 'تم تسجيل الدفع بنجاح ✅');
            }
            
            if ($input['action'] === 'unpay') {
                // إلغاء الدفع
                $stmt = $db->prepare("SELECT due_date, sale_id FROM `{$installmentsTable}` WHERE id = ? AND user_id = ?");
                $stmt->execute([$input['id'], $user_id]);
                $row = $stmt->fetch();
                
                if ($row) {
                    $newStatus = (strtotime($row['due_date']) < strtotime(date('Y-m-d'))) ? 'late' : 'pending';
                    
                    $stmt = $db->prepare("UPDATE `{$installmentsTable}` 
                                          SET status = ?, paid_date = NULL 
                                          WHERE id = ? AND user_id = ?");
                    $stmt->execute([$newStatus, $input['id'], $user_id]);
                    
                    // إعادة البيع لحالة نشط
                    $db->prepare("UPDATE `{$salesTable}` SET status = 'active' WHERE id = ? AND user_id = ?")
                       ->execute([$row['sale_id'], $user_id]);
                    
                    jsonResponse(true, null, 'تم إلغاء الدفع');
                } else {
                    jsonResponse(false, null, 'القسط غير موجود أو لا تملك صلاحية تعديله');
                }
            }
            
            if ($input['action'] === 'update_notes') {
                $stmt = $db->prepare("UPDATE `{$installmentsTable}` SET notes = ? WHERE id = ? AND user_id = ?");
                $stmt->execute([$input['notes'] ?? '', $input['id'], $user_id]);
                jsonResponse(true, null, 'تم حفظ الملاحظة');
            }
            
            break;
        
        default:
            http_response_code(405);
            jsonResponse(false, null, 'الطريقة غير مدعومة');
    }
} catch (Exception $e) {
    http_response_code(500);
    error_log('installments.php: ' . $e->getMessage());
    jsonResponse(false, null, 'حدث خطأ في معالجة الأقساط، يرجى المحاولة مرة أخرى');
}
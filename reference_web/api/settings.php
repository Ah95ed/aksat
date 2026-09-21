<?php
require_once 'config.php';

$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];
$table = tbl('settings');

// معرف المستخدم الحالي من التوكن
$user_id = getAuthUser();

try {
    switch ($method) {
        
        case 'GET':
            // جلب إعدادات المستخدم الحالي فقط
            $stmt = $db->prepare("SELECT setting_key, setting_value FROM `{$table}` WHERE user_id = ?");
            $stmt->execute([$user_id]);
            $rows = $stmt->fetchAll();
            $settings = [];
            foreach ($rows as $row) {
                $settings[$row['setting_key']] = $row['setting_value'];
            }

            // ============ عدد الأيام المتبقية على انتهاء الاشتراك (لتنبيه المستخدم) ============
            $subStmt = $db->prepare(
                "SELECT DATEDIFF(end_date, CURDATE()) AS remaining_days
                 FROM `subscriptions`
                 WHERE user_id = ? AND status = 'active'
                 ORDER BY id DESC LIMIT 1"
            );
            $subStmt->execute([$user_id]);
            $subRow = $subStmt->fetch();
            $settings['subscription_remaining_days'] = $subRow ? (int)$subRow['remaining_days'] : null;

            jsonResponse(true, $settings);
            break;
        
        case 'POST':
        case 'PUT':
            $input = getInput();
            if (empty($input)) {
                jsonResponse(false, null, 'لا توجد بيانات للتحديث');
            }
            
            $allowedKeys = ['store_name', 'currency_name', 'currency_symbol', 'exchange_rate', 'whatsapp_template'];
            foreach ($input as $key => $value) {
                if (!in_array($key, $allowedKeys, true)) {
                    http_response_code(400);
                    jsonResponse(false, null, 'إعداد غير معروف');
                }
                if (is_array($value) || is_object($value) || strlen((string)$value) > 5000) {
                    http_response_code(400);
                    jsonResponse(false, null, 'قيمة إعداد غير صالحة');
                }
                if ($key === 'store_name' && mb_strlen(trim((string)$value)) > 150) {
                    http_response_code(400);
                    jsonResponse(false, null, 'اسم المتجر طويل جداً');
                }
                if ($key === 'currency_name' && mb_strlen(trim((string)$value)) > 100) {
                    http_response_code(400);
                    jsonResponse(false, null, 'اسم العملة طويل جداً');
                }
                if ($key === 'currency_symbol' && mb_strlen(trim((string)$value)) > 20) {
                    http_response_code(400);
                    jsonResponse(false, null, 'رمز العملة غير صالح');
                }
                if ($key === 'exchange_rate' && (!is_numeric($value) || (float)$value <= 0 || (float)$value > 1000000000)) {
                    http_response_code(400);
                    jsonResponse(false, null, 'سعر الصرف غير صالح');
                }
            }

            // إدراج أو تحديث إعدادات المستخدم الحالي فقط
            $stmt = $db->prepare("INSERT INTO `{$table}` (user_id, setting_key, setting_value) 
                                  VALUES (?, ?, ?) 
                                  ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)");
            
            foreach ($input as $key => $value) {
                $stmt->execute([$user_id, $key, $value]);
            }
            
            jsonResponse(true, $input, 'تم تحديث الإعدادات بنجاح');
            break;
        
        default:
            http_response_code(405);
            jsonResponse(false, null, 'الطريقة غير مدعومة');
    }
} catch (PDOException $e) {
    http_response_code(500);
    error_log('settings.php: ' . $e->getMessage());
    jsonResponse(false, null, 'حدث خطأ في حفظ الإعدادات، يرجى المحاولة مرة أخرى');
}
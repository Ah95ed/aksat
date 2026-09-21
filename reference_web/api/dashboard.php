<?php
require_once 'config.php';

$db = getDB();
$today = date('Y-m-d');
$weekEnd = date('Y-m-d', strtotime('+7 days'));
$monthEnd = date('Y-m-d', strtotime('+30 days'));

// معرف المستخدم الحالي من التوكن
$user_id = getAuthUser();

$productsTable = tbl('products');
$customersTable = tbl('customers');
$salesTable = tbl('sales');
$installmentsTable = tbl('installments');

try {
    // تحديث المتأخرات تلقائياً (بشرط معرف المستخدم)
    $stmt = $db->prepare("UPDATE `{$installmentsTable}` 
                          SET status = 'late' 
                          WHERE status = 'pending' AND due_date < ? AND user_id = ?");
    $stmt->execute([$today, $user_id]);
    
    $stats = [];
    
    // إحصائيات عامة
    $stmt = $db->prepare("SELECT COUNT(*) FROM `{$customersTable}` WHERE user_id = ?");
    $stmt->execute([$user_id]);
    $stats['total_customers'] = $stmt->fetchColumn();
    
    $stmt = $db->prepare("SELECT COUNT(*) FROM `{$productsTable}` WHERE user_id = ?");
    $stmt->execute([$user_id]);
    $stats['total_products'] = $stmt->fetchColumn();
    
    $stmt = $db->prepare("SELECT COUNT(*) FROM `{$salesTable}` WHERE status = 'active' AND user_id = ?");
    $stmt->execute([$user_id]);
    $stats['active_sales'] = $stmt->fetchColumn();
    
    $stmt = $db->prepare("SELECT COUNT(*) FROM `{$salesTable}` WHERE status = 'completed' AND user_id = ?");
    $stmt->execute([$user_id]);
    $stats['completed_sales'] = $stmt->fetchColumn();
    
    // إجمالي المحصل (مفصل بالعملة)
    $stmt = $db->prepare("
        SELECT s.currency, COALESCE(SUM(i.amount), 0) as total
        FROM `{$installmentsTable}` i
        INNER JOIN `{$salesTable}` s ON i.sale_id = s.id
        WHERE i.status = 'paid' AND i.user_id = ?
        GROUP BY s.currency
    ");
    $stmt->execute([$user_id]);
    $collected = $stmt->fetchAll();
    
    $stats['collected'] = ['USD' => 0, 'LOCAL' => 0];
    foreach ($collected as $row) {
        $stats['collected'][$row['currency']] = floatval($row['total']);
    }
    
    // إجمالي المتبقي (مفصل بالعملة)
    $stmt = $db->prepare("
        SELECT s.currency, COALESCE(SUM(i.amount), 0) as total
        FROM `{$installmentsTable}` i
        INNER JOIN `{$salesTable}` s ON i.sale_id = s.id
        WHERE i.status IN ('pending', 'late') AND i.user_id = ?
        GROUP BY s.currency
    ");
    $stmt->execute([$user_id]);
    $remaining = $stmt->fetchAll();
    
    $stats['remaining'] = ['USD' => 0, 'LOCAL' => 0];
    foreach ($remaining as $row) {
        $stats['remaining'][$row['currency']] = floatval($row['total']);
    }
    
    // المتأخرات
    $stmt = $db->prepare("SELECT COUNT(*) FROM `{$installmentsTable}` WHERE status = 'late' AND user_id = ?");
    $stmt->execute([$user_id]);
    $stats['late_installments'] = $stmt->fetchColumn();
    
    $stmt = $db->prepare("
        SELECT s.currency, COALESCE(SUM(i.amount), 0) as total
        FROM `{$installmentsTable}` i
        INNER JOIN `{$salesTable}` s ON i.sale_id = s.id
        WHERE i.status = 'late' AND i.user_id = ?
        GROUP BY s.currency
    ");
    $stmt->execute([$user_id]);
    $lateAmount = $stmt->fetchAll();
    
    $stats['late_amount'] = ['USD' => 0, 'LOCAL' => 0];
    foreach ($lateAmount as $row) {
        $stats['late_amount'][$row['currency']] = floatval($row['total']);
    }
    
    // الأقساط المستحقة هذا الأسبوع
    $stmt = $db->prepare("
        SELECT COUNT(*) as count, 
               s.currency,
               COALESCE(SUM(i.amount), 0) as total
        FROM `{$installmentsTable}` i
        INNER JOIN `{$salesTable}` s ON i.sale_id = s.id
        WHERE i.status = 'pending' AND i.user_id = ? AND i.due_date BETWEEN ? AND ?
        GROUP BY s.currency
    ");
    $stmt->execute([$user_id, $today, $weekEnd]);
    $weekData = $stmt->fetchAll();
    
    $stats['upcoming_week'] = ['count' => 0, 'USD' => 0, 'LOCAL' => 0];
    foreach ($weekData as $row) {
        $stats['upcoming_week']['count'] += intval($row['count']);
        $stats['upcoming_week'][$row['currency']] = floatval($row['total']);
    }
    
    // الأقساط المستحقة هذا الشهر
    $stmt = $db->prepare("
        SELECT COUNT(*) as count, 
               s.currency,
               COALESCE(SUM(i.amount), 0) as total
        FROM `{$installmentsTable}` i
        INNER JOIN `{$salesTable}` s ON i.sale_id = s.id
        WHERE i.status = 'pending' AND i.user_id = ? AND i.due_date BETWEEN ? AND ?
        GROUP BY s.currency
    ");
    $stmt->execute([$user_id, $today, $monthEnd]);
    $monthData = $stmt->fetchAll();
    
    $stats['upcoming_month'] = ['count' => 0, 'USD' => 0, 'LOCAL' => 0];
    foreach ($monthData as $row) {
        $stats['upcoming_month']['count'] += intval($row['count']);
        $stats['upcoming_month'][$row['currency']] = floatval($row['total']);
    }
    
    // أكثر المواد مبيعاً
    $stmt = $db->prepare("
        SELECT product_name, COUNT(*) as sales_count
        FROM `{$salesTable}`
        WHERE user_id = ?
        GROUP BY product_id, product_name
        ORDER BY sales_count DESC
        LIMIT 5
    ");
    $stmt->execute([$user_id]);
    $stats['top_products'] = $stmt->fetchAll();
    
    // آخر العمليات
    $stmt = $db->prepare("
        SELECT s.id, s.product_name, s.total_price, s.currency, s.created_at,
               c.name as customer_name
        FROM `{$salesTable}` s
        INNER JOIN `{$customersTable}` c ON s.customer_id = c.id
        WHERE s.user_id = ?
        ORDER BY s.created_at DESC
        LIMIT 5
    ");
    $stmt->execute([$user_id]);
    $stats['recent_sales'] = $stmt->fetchAll();
    
    // ============ تنبيهات المخزون ============
    $inventoryTable = tbl('inventory');
    
    // التحقق من وجود جدول المخزن
    try {
        $stmt = $db->prepare("
            SELECT i.product_id, i.quantity, i.low_stock_threshold,
                   p.name as product_name, p.price, p.currency
            FROM `{$inventoryTable}` i
            INNER JOIN `{$productsTable}` p ON i.product_id = p.id
            WHERE i.quantity <= i.low_stock_threshold AND i.user_id = ?
            ORDER BY i.quantity ASC
            LIMIT 10
        ");
        $stmt->execute([$user_id]);
        $stats['low_stock_items'] = $stmt->fetchAll();
        
        $stmt = $db->prepare("SELECT COUNT(*) FROM `{$inventoryTable}` WHERE user_id = ?");
        $stmt->execute([$user_id]);
        $stats['inventory_tracked_count'] = $stmt->fetchColumn();
        
        $stmt = $db->prepare("SELECT COUNT(*) FROM `{$inventoryTable}` WHERE quantity <= 0 AND user_id = ?");
        $stmt->execute([$user_id]);
        $stats['out_of_stock_count'] = $stmt->fetchColumn();
    } catch (Exception $e) {
        // جدول المخزن غير موجود
        $stats['low_stock_items'] = [];
        $stats['inventory_tracked_count'] = 0;
        $stats['out_of_stock_count'] = 0;
    }
    
    jsonResponse(true, $stats);
    
} catch (Exception $e) {
    http_response_code(500);
    error_log('dashboard.php: ' . $e->getMessage());
    jsonResponse(false, null, 'حدث خطأ في لوحة التحكم، يرجى المحاولة مرة أخرى');
}
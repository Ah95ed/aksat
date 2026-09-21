<?php
require_once 'config.php';

$db = getDB();
$salesTable = tbl('sales');
$installmentsTable = tbl('installments');
$customersTable = tbl('customers');
$productsTable = tbl('products');

// معرف المستخدم الحالي من التوكن
$user_id = getAuthUser();

try {
    $type = $_GET['type'] ?? 'summary';
    $period = $_GET['period'] ?? 'all';
    $currency = $_GET['currency'] ?? 'all';
    
    // ============ تحديد نطاق التاريخ حسب الفترة ============
    $dateFrom = null;
    $dateTo = date('Y-m-d');
    
    switch ($period) {
        case 'today':
            $dateFrom = date('Y-m-d');
            break;
        case 'week':
            $dateFrom = date('Y-m-d', strtotime('-7 days'));
            break;
        case 'month':
            $dateFrom = date('Y-m-01'); // أول الشهر الحالي
            break;
        case 'last_month':
            $dateFrom = date('Y-m-01', strtotime('-1 month'));
            $dateTo = date('Y-m-t', strtotime('-1 month'));
            break;
        case 'year':
            $dateFrom = date('Y-01-01');
            break;
        case 'custom':
            $dateFrom = $_GET['from'] ?? null;
            $dateTo = $_GET['to'] ?? date('Y-m-d');
            break;
        case 'all':
        default:
            $dateFrom = null;
            break;
    }
    
    // شرط الفترة
    $dateCondition = '';
    $dateParams = [];
    if ($dateFrom) {
        $dateCondition = " AND s.sale_date BETWEEN ? AND ?";
        $dateParams = [$dateFrom, $dateTo];
    }
    
    // شرط العملة
    $currencyCondition = '';
    $currencyParams = [];
    if ($currency !== 'all') {
        $currencyCondition = " AND s.currency = ?";
        $currencyParams = [$currency];
    }
    
    switch ($type) {
        
        // ============ ملخص الأرباح ============
        case 'summary':
            $result = [
                'period' => $period,
                'date_from' => $dateFrom,
                'date_to' => $dateTo,
                'USD' => initStats(),
                'LOCAL' => initStats()
            ];
            
            // الربح المتوقع (كل المبيعات في الفترة)
            $stmt = $db->prepare("
                SELECT 
                    s.currency,
                    COUNT(s.id) as sales_count,
                    SUM(s.quantity) as items_sold,
                    SUM(s.total_price) as total_revenue,
                    SUM(s.cost_price_at_sale * s.quantity) as total_cost,
                    SUM(s.total_price - (s.cost_price_at_sale * s.quantity)) as expected_profit
                FROM `{$salesTable}` s
                WHERE s.user_id = ? {$dateCondition} {$currencyCondition}
                GROUP BY s.currency
            ");
            $stmt->execute(array_merge([$user_id], $dateParams, $currencyParams));
            
            while ($row = $stmt->fetch()) {
                $cur = $row['currency'];
                $result[$cur]['sales_count'] = intval($row['sales_count']);
                $result[$cur]['items_sold'] = intval($row['items_sold']);
                $result[$cur]['total_revenue'] = floatval($row['total_revenue']);
                $result[$cur]['total_cost'] = floatval($row['total_cost']);
                $result[$cur]['expected_profit'] = floatval($row['expected_profit']);
            }
            
            // الربح الفعلي (الأقساط المدفوعة + المقدمة)
            $stmt = $db->prepare("
                SELECT 
                    s.currency,
                    SUM(s.down_payment) as collected_down_payment,
                    SUM(s.cost_price_at_sale * s.quantity) as total_cost_all
                FROM `{$salesTable}` s
                WHERE s.user_id = ? {$dateCondition} {$currencyCondition}
                GROUP BY s.currency
            ");
            $stmt->execute(array_merge([$user_id], $dateParams, $currencyParams));
            $downPayments = [];
            while ($row = $stmt->fetch()) {
                $downPayments[$row['currency']] = floatval($row['collected_down_payment']);
            }
            
            // الأقساط المدفوعة في الفترة 
            $instCondition = '';
            $instParams = [];
            if ($dateFrom) {
                $instCondition = " AND i.paid_date BETWEEN ? AND ?";
                $instParams = [$dateFrom, $dateTo];
            }
            
            $stmt = $db->prepare("
                SELECT 
                    s.currency,
                    SUM(i.amount) as paid_amount
                FROM `{$installmentsTable}` i
                INNER JOIN `{$salesTable}` s ON i.sale_id = s.id
                WHERE i.status = 'paid' AND i.user_id = ? {$instCondition} {$currencyCondition}
                GROUP BY s.currency
            ");
            $stmt->execute(array_merge([$user_id], $instParams, $currencyParams));
            
            $collectedFromInstallments = ['USD' => 0, 'LOCAL' => 0];
            while ($row = $stmt->fetch()) {
                $collectedFromInstallments[$row['currency']] = floatval($row['paid_amount']);
            }
            
            // حساب الربح الفعلي
            foreach (['USD', 'LOCAL'] as $cur) {
                $totalCollected = ($downPayments[$cur] ?? 0) + ($collectedFromInstallments[$cur] ?? 0);
                $result[$cur]['total_collected'] = $totalCollected;
                
                if ($result[$cur]['total_revenue'] > 0) {
                    $collectionRate = $totalCollected / $result[$cur]['total_revenue'];
                    $result[$cur]['actual_profit'] = round($result[$cur]['expected_profit'] * $collectionRate, 2);
                } else {
                    $result[$cur]['actual_profit'] = 0;
                }
            }
            
            jsonResponse(true, $result);
            break;
        
        // ============ الربح حسب المادة ============
        case 'by_product':
            $stmt = $db->prepare("
                SELECT 
                    s.product_id,
                    s.product_name,
                    s.currency,
                    COUNT(s.id) as sales_count,
                    SUM(s.quantity) as total_quantity,
                    SUM(s.total_price) as total_revenue,
                    SUM(s.cost_price_at_sale * s.quantity) as total_cost,
                    SUM(s.total_price - (s.cost_price_at_sale * s.quantity)) as expected_profit,
                    AVG(s.cost_price_at_sale) as avg_cost,
                    AVG(s.total_price / s.quantity) as avg_unit_price
                FROM `{$salesTable}` s
                WHERE s.user_id = ? {$dateCondition} {$currencyCondition}
                GROUP BY s.product_id, s.product_name, s.currency
                ORDER BY expected_profit DESC
            ");
            $stmt->execute(array_merge([$user_id], $dateParams, $currencyParams));
            
            jsonResponse(true, $stmt->fetchAll());
            break;
        
        // ============ أكثر المواد مبيعاً ============
        case 'top_selling':
            $stmt = $db->prepare("
                SELECT 
                    s.product_id,
                    s.product_name,
                    s.currency,
                    COUNT(s.id) as sales_count,
                    SUM(s.quantity) as total_quantity,
                    SUM(s.total_price) as total_revenue,
                    SUM(s.total_price - (s.cost_price_at_sale * s.quantity)) as expected_profit
                FROM `{$salesTable}` s
                WHERE s.user_id = ? {$dateCondition} {$currencyCondition}
                GROUP BY s.product_id, s.product_name, s.currency
                ORDER BY total_quantity DESC
                LIMIT 20
            ");
            $stmt->execute(array_merge([$user_id], $dateParams, $currencyParams));
            
            jsonResponse(true, $stmt->fetchAll());
            break;
        
        // ============ الأرباح حسب الفترة (يومي/شهري) ============
        case 'timeline':
            $groupBy = $_GET['group_by'] ?? 'month';
            
            switch ($groupBy) {
                case 'day':
                    $dateFormat = '%Y-%m-%d';
                    $label = 'DATE_FORMAT(s.sale_date, "%Y-%m-%d")';
                    break;
                case 'week':
                    $label = 'CONCAT(YEAR(s.sale_date), "-W", LPAD(WEEK(s.sale_date), 2, "0"))';
                    break;
                case 'month':
                    $label = 'DATE_FORMAT(s.sale_date, "%Y-%m")';
                    break;
                case 'year':
                    $label = 'YEAR(s.sale_date)';
                    break;
                default:
                    $label = 'DATE_FORMAT(s.sale_date, "%Y-%m")';
            }
            
            $stmt = $db->prepare("
                SELECT 
                    {$label} as period,
                    s.currency,
                    COUNT(s.id) as sales_count,
                    SUM(s.quantity) as items_sold,
                    SUM(s.total_price) as total_revenue,
                    SUM(s.cost_price_at_sale * s.quantity) as total_cost,
                    SUM(s.total_price - (s.cost_price_at_sale * s.quantity)) as expected_profit
                FROM `{$salesTable}` s
                WHERE s.user_id = ? {$dateCondition} {$currencyCondition}
                GROUP BY period, s.currency
                ORDER BY period DESC
                LIMIT 24
            ");
            $stmt->execute(array_merge([$user_id], $dateParams, $currencyParams));
            
            jsonResponse(true, $stmt->fetchAll());
            break;
        
        // ============ تفاصيل ربح مادة واحدة ============
        case 'product_detail':
            $productId = $_GET['product_id'] ?? null;
            if (!$productId) {
                jsonResponse(false, null, 'معرف المادة مطلوب');
            }
            
            $stmt = $db->prepare("
                SELECT s.*, c.name as customer_name
                FROM `{$salesTable}` s
                INNER JOIN `{$customersTable}` c ON s.customer_id = c.id
                WHERE s.product_id = ? AND s.user_id = ? {$dateCondition}
                ORDER BY s.sale_date DESC
            ");
            $stmt->execute(array_merge([$productId, $user_id], $dateParams));
            
            jsonResponse(true, $stmt->fetchAll());
            break;
        
        default:
            jsonResponse(false, null, 'نوع التقرير غير معروف');
    }
    
} catch (Exception $e) {
    http_response_code(500);
    error_log('reports.php: ' . $e->getMessage());
    jsonResponse(false, null, 'حدث خطأ في إنشاء التقرير، يرجى المحاولة مرة أخرى');
}

function initStats() {
    return [
        'sales_count' => 0,
        'items_sold' => 0,
        'total_revenue' => 0,
        'total_cost' => 0,
        'expected_profit' => 0,
        'total_collected' => 0,
        'actual_profit' => 0
    ];
}
<?php
require_once 'config.php';

/**
 * التحقق من هوية المستخدم وحالة اشتراكه الفعلية في قاعدة البيانات مع كل طلب
 */
function authenticateUser() {
    // 1. جلب بيانات المستخدم من رمز التوكين (JWT)
    $user = getAuthUser();

    if (!$user) {
        http_response_code(401);
        echo json_encode(['status' => 'error', 'message' => 'غير مصرح بالدخول']);
        exit;
    }

    // استخراج معرف المستخدم (سواء كان الكائن Matrix/Array أو Object)
    $userId = is_array($user) ? ($user['id'] ?? $user['user_id'] ?? null) : ($user->id ?? $user->user_id ?? null);

    if (!$userId) {
        http_response_code(401);
        echo json_encode(['status' => 'error', 'message' => 'بيانات الجلسة غير صالحة']);
        exit;
    }

    // 2. الفحص اللحظي لحالة الاشتراك من قاعدة البيانات عبر $pdo المعرف في config.php
    global $pdo;

    $stmt = $pdo->prepare("SELECT status FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $dbUser = $stmt->fetch(PDO::FETCH_ASSOC);

    // 3. رفض الطلب فوراً برمز 401 إذا تم إلغاء الاشتراك أو إيقاف الحساب
    if (!$dbUser || (isset($dbUser['status']) && $dbUser['status'] !== 'active')) {
        http_response_code(401);
        echo json_encode([
            'status' => 'error',
            'message' => 'تم إلغاء اشتراكك أو إيقاف حسابك.',
            'code' => 'SUBSCRIPTION_INACTIVE'
        ]);
        exit;
    }

    return $user;
}
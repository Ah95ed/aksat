<?php
require_once 'config.php';
require_once '../vendor/autoload.php'; // استدعاء مكتبة JWT

use \Firebase\JWT\JWT;

$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];

if ($method !== 'POST') {
    http_response_code(405);
    jsonResponse(false, null, 'الطريقة غير مدعومة');
}

$input = getInput();

if (empty($input['email']) || empty($input['password'])) {
    jsonResponse(false, null, 'الرجاء إدخال البريد الإلكتروني وكلمة المرور');
}

$email = strtolower(trim((string)$input['email']));
$password = $input['password'];

// ============ Rate Limiting: بحد أقصى 5 محاولات فاشلة كل 5 دقائق لكل IP+بريد ============
$clientIp = getClientIp();
$rateLimitKey = 'login_' . $clientIp . '_' . strtolower($email);
[$rateLimitFile, $rateLimitData] = checkRateLimit($rateLimitKey, 5, 300);

try {
    // البحث عن المستخدم
    $stmt = $db->prepare("SELECT id, name, password, role, subscription_status FROM `users` WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    // التحقق من وجود المستخدم وصحة كلمة المرور
    if ($user && password_verify($password, $user['password'])) {

        // منع دخول أصحاب المتاجر (غير الأدمن) إذا كان اشتراكهم موقوفاً أو منتهياً
        if ($user['role'] !== 'admin') {
            $db->prepare("UPDATE `subscriptions` SET status = 'expired' WHERE user_id = ? AND status = 'active' AND end_date < CURDATE()")
               ->execute([$user['id']]);

            $stmt2 = $db->prepare("SELECT status FROM `subscriptions` WHERE user_id = ? ORDER BY id DESC LIMIT 1");
            $stmt2->execute([$user['id']]);
            $latest = $stmt2->fetch();

if ($latest && $latest['status'] !== 'active') {
    $db->prepare("UPDATE `users` SET subscription_status = ? WHERE id = ?")->execute([$latest['status'], $user['id']]);
    http_response_code(403);
    jsonResponse(false, [
        'code' => 'SUBSCRIPTION_STOPPED',
        'whatsapp' => '9647706118992'
    ], 'تم إيقاف اشتراكك، يرجى التواصل مع الإدارة لتجديد الاشتراك');
}
        }

        // تسجيل دخول ناجح: تصفير عداد المحاولات الفاشلة لهذا المفتاح
        clearRateLimit($rateLimitFile);

        // إعداد بيانات التوكن (Payload)
        $issuedAt = time();
        $expirationTime = $issuedAt + 86400; // التوكن صالح لمدة 24 ساعة فقط
        
        $payload = [
            'iat' => $issuedAt,
            'exp' => $expirationTime,
            'user_id' => $user['id'],
            'name' => $user['name']
        ];
        
        // توليد التوكن
        $jwt = JWT::encode($payload, JWT_SECRET, 'HS256');
        
        jsonResponse(true, [
            'token' => $jwt,
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'role' => $user['role']
            ]
        ], 'تم تسجيل الدخول بنجاح');
        
    } else {
        // تسجيل محاولة فاشلة (بريد غير صحيح أو كلمة مرور خاطئة) لأغراض Rate Limiting
        recordFailedAttempt($rateLimitFile, $rateLimitData, 5, 300, 900);
        http_response_code(401);
        jsonResponse(false, null, 'البريد الإلكتروني أو كلمة المرور غير صحيحة');
    }
    
} catch (Throwable $e) {
    error_log('login.php: ' . $e->getMessage());
    http_response_code(500);
    jsonResponse(false, null, 'حدث خطأ أثناء تسجيل الدخول، يرجى المحاولة مرة أخرى');
}
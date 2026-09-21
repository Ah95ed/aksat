<?php
// ملاحظة: display_errors مُعطّل الآن مركزياً داخل config.php (وضع الإنتاج)
require_once 'config.php';

// فحص مسار autoload بشكل آمن لتجنب خطأ 500
$vendorPath1 = __DIR__ . '/../vendor/autoload.php';
$vendorPath2 = __DIR__ . '/vendor/autoload.php';

if (file_exists($vendorPath1)) {
    require_once $vendorPath1;
} elseif (file_exists($vendorPath2)) {
    require_once $vendorPath2;
} else {
    http_response_code(500);
    jsonResponse(false, null, 'مكتبة JWT غير مثبتة في مجلد vendor');
}

use \Firebase\JWT\JWT;

$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];

if ($method !== 'POST') {
    http_response_code(405);
    jsonResponse(false, null, 'الطريقة غير مدعومة');
}

$input = getInput();

// التحقق من المدخلات الأساسية
if (empty($input['name']) || empty($input['email']) || empty($input['password'])) {
    jsonResponse(false, null, 'الرجاء إدخال الاسم، البريد الإلكتروني، وكلمة المرور');
}

$name = strip_tags(trim($input['name']));
$email = strtolower(trim((string)$input['email']));
$password = (string)$input['password'];

if (mb_strlen($name) < 2 || mb_strlen($name) > 100) {
    http_response_code(400);
    jsonResponse(false, null, 'الاسم يجب أن يكون بين 2 و100 حرف');
}
if (strlen($password) < 8 || strlen($password) > 200) {
    http_response_code(400);
    jsonResponse(false, null, 'كلمة المرور يجب أن تكون بين 8 و200 حرف');
}

$clientIp = getClientIp();
[$registrationRateFile, $registrationRateData] = checkRateLimit('register_' . $clientIp, 5, 600);
recordFailedAttempt($registrationRateFile, $registrationRateData, 5, 600, 900);

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    jsonResponse(false, null, 'صيغة البريد الإلكتروني غير صحيحة');
}

try {
    // 1. التحقق من وجود البريد الإلكتروني
    $stmt = $db->prepare("SELECT id FROM `users` WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        jsonResponse(false, null, 'البريد الإلكتروني مسجل مسبقاً، يرجى تسجيل الدخول.');
    }

    // 2. تشفير كلمة المرور
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    // 3. إدراج المستخدم الجديد
    $stmt = $db->prepare("INSERT INTO `users` (name, email, password, role) VALUES (?, ?, ?, 'user')");
    $stmt->execute([$name, $email, $hashedPassword]);
    
    $newUserId = $db->lastInsertId();

    // 4. توليد التوكن بتنسيق متوافق مع config.php
    $issuedAt = time();
    $expirationTime = $issuedAt + 86400;
    
    $payload = [
        'iat' => $issuedAt,
        'exp' => $expirationTime,
        'data' => [
            'id' => $newUserId,
            'name' => $name,
            'email' => $email
        ]
    ];
    
    $jwt = JWT::encode($payload, JWT_SECRET, 'HS256');
    
    jsonResponse(true, [
        'token' => $jwt,
        'user' => [
            'id' => $newUserId,
            'name' => $name,
            'email' => $email
        ]
    ], 'تم إنشاء الحساب وتسجيل الدخول بنجاح ✅');

} catch (Throwable $e) {
    error_log('register.php: ' . $e->getMessage());
    http_response_code(500);
    jsonResponse(false, null, 'حدث خطأ أثناء التسجيل، يرجى المحاولة مرة أخرى');
}
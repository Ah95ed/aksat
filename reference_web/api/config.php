<?php
/**
 * ============================================
 * إعدادات المشروع - نظام إدارة الأقساط
 * ============================================
 */

// ============ وضع الإنتاج: تعطيل عرض الأخطاء ============
// لا تعرض تفاصيل الأخطاء البرمجية للمستخدم (تمنع تسريب مسارات
// السيرفر واستعلامات SQL وغيرها). الأخطاء تُسجَّل في سجل السيرفر بدلاً من ذلك.
ini_set('display_errors', '0');
ini_set('display_startup_errors', '0');
error_reporting(E_ALL);
ini_set('log_errors', '1');
// اختياري: عيّن مسار سجل مخصص إن رغبت
// ini_set('error_log', __DIR__ . '/../php-error.log');

// ============ الأسرار وبيانات قاعدة البيانات ============
// القيم الحساسة موجودة في api/config.local.php أو متغيرات البيئة، ولا ينبغي
// وضعها في GitHub. متغيرات البيئة لها الأولوية على الملف المحلي.
$localConfigPath = __DIR__ . '/config.local.php';
$localConfig = file_exists($localConfigPath) ? (require $localConfigPath) : [];

$jwtSecret = getenv('AKSAT_JWT_SECRET') ?: ($localConfig['JWT_SECRET'] ?? '');
if (!is_string($jwtSecret) || strlen($jwtSecret) < 32) {
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['success' => false, 'data' => null, 'message' => 'إعداد الأمان JWT غير مكتمل على الخادم'], JSON_UNESCAPED_UNICODE);
    exit();
}
define('JWT_SECRET', $jwtSecret);

define('DB_HOST', getenv('AKSAT_DB_HOST') ?: ($localConfig['DB_HOST'] ?? 'localhost'));
define('DB_NAME', getenv('AKSAT_DB_NAME') ?: ($localConfig['DB_NAME'] ?? ''));
define('DB_USER', getenv('AKSAT_DB_USER') ?: ($localConfig['DB_USER'] ?? ''));
define('DB_PASS', getenv('AKSAT_DB_PASS') ?: ($localConfig['DB_PASS'] ?? ''));
define('DB_CHARSET', 'utf8mb4');

// ============ إعدادات CORS: قصر على نطاقك فقط ============
$allowedOrigins = $localConfig['APP_ORIGINS'] ?? [
    'https://aksat.store',
    'https://www.aksat.store',
];
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
if (in_array($origin, $allowedOrigins, true)) {
    header('Access-Control-Allow-Origin: ' . $origin);
}
header('Vary: Origin');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Authorization');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json; charset=utf-8');

// ============ Security Headers ============
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('Referrer-Policy: strict-origin-when-cross-origin');
header('Permissions-Policy: geolocation=(), microphone=(), camera=()');
// HSTS: فعّالة فقط عبر HTTPS (تأكد أن الموقع يعمل بالكامل عبر HTTPS قبل رفعها لمدة طويلة)
if (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') {
    header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
}
// CSP بسيطة تناسب واجهة API (JSON فقط، لا HTML يُعرض من هنا)
header("Content-Security-Policy: default-src 'none'; frame-ancestors 'none'");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ============ الدوال المساعدة (تُعرف أولاً) ============

// دالة إرسال استجابة JSON
function jsonResponse($success, $data = null, $message = '') {
    echo json_encode([
        'success' => $success,
        'data' => $data,
        'message' => $message
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

// دالة مساعدة لاسم الجدول
function tbl($name) {
    return $name;
}

// دالة قراءة البيانات الواردة
function getInput() {
    $input = json_decode(file_get_contents('php://input'), true);
    return $input ?: [];
}

// ============ الاتصال بقاعدة البيانات ============
function getDB() {
    try {
        $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];
        return new PDO($dsn, DB_USER, DB_PASS, $options);
    } catch (PDOException $e) {
        http_response_code(500);
        error_log('Database connection error: ' . $e->getMessage());
        jsonResponse(false, null, 'تعذر الاتصال بقاعدة البيانات، يرجى مراجعة إعدادات الخادم');
    }
}

// عنوان العميل: لا نثق بـ X-Forwarded-For افتراضياً لأنه قابل للتزوير.
function getClientIp() {
    return $_SERVER['REMOTE_ADDR'] ?? 'unknown';
}

// ============ Rate Limiting (لمنع محاولات تخمين كلمة المرور) ============
// تخزين بسيط في ملف (مناسب للاستضافة المشتركة بدون Redis/Memcached).
// يحظر بعد $maxAttempts محاولة فاشلة خلال $windowSeconds ثانية، لكل (IP + بريد إلكتروني).
function checkRateLimit($key, $maxAttempts = 5, $windowSeconds = 300) {
    $dir = sys_get_temp_dir() . '/aksat_ratelimit';
    if (!is_dir($dir)) {
        @mkdir($dir, 0700, true);
    }
    $safeKey = preg_replace('/[^a-zA-Z0-9_]/', '_', $key);
    $file = $dir . '/' . $safeKey . '.json';

    $now = time();
    $data = ['attempts' => [], 'blocked_until' => 0];

    if (file_exists($file)) {
        $raw = @file_get_contents($file);
        $decoded = $raw ? json_decode($raw, true) : null;
        if (is_array($decoded)) {
            $data = $decoded;
        }
    }

    if (!empty($data['blocked_until']) && $data['blocked_until'] > $now) {
        $retryAfter = $data['blocked_until'] - $now;
        http_response_code(429);
        jsonResponse(false, ['retry_after_seconds' => $retryAfter], 'محاولات كثيرة جداً. الرجاء المحاولة بعد ' . ceil($retryAfter / 60) . ' دقيقة');
    }

    // إزالة المحاولات القديمة خارج النافذة الزمنية
    $data['attempts'] = array_values(array_filter($data['attempts'], function ($t) use ($now, $windowSeconds) {
        return ($now - $t) < $windowSeconds;
    }));

    return [$file, $data];
}

// يُستدعى بعد فشل محاولة تسجيل الدخول
function recordFailedAttempt($file, $data, $maxAttempts = 5, $windowSeconds = 300, $blockSeconds = 900) {
    $now = time();
    $data['attempts'][] = $now;
    if (count($data['attempts']) >= $maxAttempts) {
        $data['blocked_until'] = $now + $blockSeconds;
        $data['attempts'] = [];
    }
    @file_put_contents($file, json_encode($data), LOCK_EX);
}

// يُستدعى بعد نجاح تسجيل الدخول لتصفير العداد
function clearRateLimit($file) {
    @file_put_contents($file, json_encode(['attempts' => [], 'blocked_until' => 0]), LOCK_EX);
}

// ============ التحقق من المستخدم (التوكن) ============
function getAuthUser() {
    // تحميل مكتبة JWT مرة واحدة.
    $vendorPath = __DIR__ . '/../vendor/autoload.php';
    if (file_exists($vendorPath)) {
        require_once $vendorPath;
    }

    /*
     * Apache/PHP على WAMP قد لا يمرر Authorization إلى PHP بنفس الطريقة
     * في كل الإعدادات، لذلك نقرأه من أكثر من مصدر.
     */
    $authHeader = '';

    if (function_exists('getallheaders')) {
        $headers = getallheaders();
        foreach ($headers as $name => $value) {
            if (strcasecmp($name, 'Authorization') === 0) {
                $authHeader = trim($value);
                break;
            }
        }
    }

    if ($authHeader === '' && function_exists('apache_request_headers')) {
        $headers = apache_request_headers();
        foreach ($headers as $name => $value) {
            if (strcasecmp($name, 'Authorization') === 0) {
                $authHeader = trim($value);
                break;
            }
        }
    }

    // دعم Apache mod_rewrite / CGI / FastCGI.
    if ($authHeader === '') {
        $authHeader = trim((string)($_SERVER['HTTP_AUTHORIZATION'] ?? ''));
    }
    if ($authHeader === '') {
        $authHeader = trim((string)($_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? ''));
    }
    if ($authHeader === '') {
        $authHeader = trim((string)($_SERVER['Authorization'] ?? ''));
    }

    // fallback: X-Authorization يصل إلى PHP حتى عندما يمنع Apache تمرير Authorization.
    if ($authHeader === '') {
        $authHeader = trim((string)($_SERVER['HTTP_X_AUTHORIZATION'] ?? ''));
    }

    if ($authHeader === '' || !preg_match('/^Bearer\s+(.+)$/i', $authHeader, $matches)) {
        http_response_code(401);
        jsonResponse(false, null, 'التوكن غير موجود. يرجى تسجيل الدخول مرة أخرى');
    }

    $token = trim($matches[1]);

    try {
        $decoded = \Firebase\JWT\JWT::decode(
            $token,
            new \Firebase\JWT\Key(JWT_SECRET, 'HS256')
        );

        $userId = null;
        if (isset($decoded->user_id)) {
            $userId = (int)$decoded->user_id;
        } elseif (isset($decoded->data->id)) {
            // توافق مع أي توكن قديم.
            $userId = (int)$decoded->data->id;
        }

        if (!$userId) {
            throw new Exception('معرف المستخدم غير موجود في التوكن');
        }

        // ============ فحص حالة الاشتراك (لا يُطبّق على الأدمن) ============
        $db = getDB();
        $stmt = $db->prepare("SELECT role, subscription_status FROM `users` WHERE id = ?");
        $stmt->execute([$userId]);
        $u = $stmt->fetch();

        if (!$u) {
            http_response_code(401);
            jsonResponse(false, null, 'الحساب غير موجود');
        }

        if ($u['role'] !== 'admin') {
            // تحديث حالة أي اشتراك منتهي تلقائياً إلى "منتهي"
            $db->prepare("UPDATE `subscriptions` SET status = 'expired' WHERE user_id = ? AND status = 'active' AND end_date < CURDATE()")
               ->execute([$userId]);

            $stmt2 = $db->prepare("SELECT status FROM `subscriptions` WHERE user_id = ? ORDER BY id DESC LIMIT 1");
            $stmt2->execute([$userId]);
            $latest = $stmt2->fetch();
            $effectiveStatus = $latest ? $latest['status'] : $u['subscription_status'];

            if ($effectiveStatus !== 'active') {
                $db->prepare("UPDATE `users` SET subscription_status = ? WHERE id = ?")->execute([$effectiveStatus, $userId]);
                http_response_code(403);
                jsonResponse(false, null, 'تم إيقاف اشتراكك، يرجى التواصل مع الإدارة لتجديد الاشتراك');
            }
        }

        return $userId;
    } catch (Throwable $e) {
        error_log('JWT authentication error: ' . $e->getMessage());
        http_response_code(401);
        jsonResponse(false, null, 'التوكن غير صالح أو انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى');
    }
}

// ============ التحقق من صلاحية الأدمن ============
function requireAdmin() {
    $userId = getAuthUser();
    $db = getDB();
    $stmt = $db->prepare("SELECT id, name, email, role FROM `users` WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();

    if (!$user || $user['role'] !== 'admin') {
        http_response_code(403);
        jsonResponse(false, null, 'غير مصرح لك بالوصول لهذه الصفحة');
    }

    return $user;
}

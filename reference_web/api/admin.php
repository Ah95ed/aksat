<?php
require_once 'config.php';

$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

// كل شيء في هذا الملف يتطلب صلاحية أدمن
$admin = requireAdmin();

// ============ GET ============
if ($method === 'GET') {

    if ($action === 'me') {
        jsonResponse(true, $admin);
    }

    if ($action === 'admins') {
        $stmt = $db->query("SELECT id, name, email, created_at FROM `users` WHERE role = 'admin' ORDER BY id ASC");
        jsonResponse(true, $stmt->fetchAll());
    }

    if ($action === 'subscribers') {
        // تحديث الاشتراكات المنتهية تلقائياً
        $db->exec("UPDATE `subscriptions` SET status = 'expired' WHERE status = 'active' AND end_date < CURDATE()");

        $sql = "SELECT
                    u.id, u.name, u.email, u.created_at, u.subscription_status,
                    s.id AS subscription_id, s.duration_value, s.duration_unit,
                    s.start_date, s.end_date, s.status AS current_sub_status,
                    DATEDIFF(s.end_date, CURDATE()) AS remaining_days
                FROM `users` u
                LEFT JOIN `subscriptions` s ON s.id = (
                    SELECT id FROM `subscriptions` WHERE user_id = u.id ORDER BY id DESC LIMIT 1
                )
                WHERE u.role = 'user'
                ORDER BY u.id DESC";
        $stmt = $db->query($sql);
        $rows = $stmt->fetchAll();

        // مزامنة عمود الحالة المختصر مع آخر اشتراك
        foreach ($rows as $r) {
            $status = $r['current_sub_status'] ?? 'active';
            if ($status !== $r['subscription_status']) {
                $db->prepare("UPDATE `users` SET subscription_status = ? WHERE id = ?")->execute([$status, $r['id']]);
            }
        }

        jsonResponse(true, $rows);
    }

    http_response_code(404);
    jsonResponse(false, null, 'إجراء غير معروف');
}

// ============ POST ============
if ($method === 'POST') {
    $input = getInput();

    if ($action === 'add_admin') {
        if (empty($input['email'])) {
            jsonResponse(false, null, 'الرجاء إدخال البريد الإلكتروني');
        }
        $email = strtolower(trim((string)$input['email']));
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            http_response_code(400);
            jsonResponse(false, null, 'البريد الإلكتروني غير صالح');
        }

        $stmt = $db->prepare("SELECT id, role FROM `users` WHERE email = ?");
        $stmt->execute([$email]);
        $target = $stmt->fetch();

        if (!$target) {
            jsonResponse(false, null, 'لا يوجد حساب مسجل بهذا البريد الإلكتروني. يجب أن يقوم الشخص بإنشاء حساب أولاً');
        }
        if ($target['role'] === 'admin') {
            jsonResponse(false, null, 'هذا الحساب أدمن بالفعل');
        }

        $db->prepare("UPDATE `users` SET role = 'admin' WHERE id = ?")->execute([$target['id']]);
        jsonResponse(true, null, 'تمت إضافة الأدمن بنجاح');
    }

    if ($action === 'remove_admin') {
        if (empty($input['user_id'])) {
            jsonResponse(false, null, 'معرف المستخدم مطلوب');
        }
        $targetId = (int)$input['user_id'];

        if ($targetId === (int)$admin['id']) {
            jsonResponse(false, null, 'لا يمكنك إلغاء صلاحية الأدمن عن نفسك');
        }

        $count = (int)$db->query("SELECT COUNT(*) c FROM `users` WHERE role = 'admin'")->fetch()['c'];
        if ($count <= 1) {
            jsonResponse(false, null, 'لا يمكن إزالة آخر أدمن في النظام');
        }

        $db->prepare("UPDATE `users` SET role = 'user', subscription_status = 'active' WHERE id = ? AND role = 'admin'")->execute([$targetId]);
        jsonResponse(true, null, 'تم إلغاء صلاحية الأدمن بنجاح');
    }

    if ($action === 'set_subscription') {
        if (empty($input['user_id']) || empty($input['duration_value']) || empty($input['duration_unit'])) {
            jsonResponse(false, null, 'الرجاء إدخال المستخدم، والمدة، والوحدة');
        }
        $targetId = (int)$input['user_id'];
        $value = (int)$input['duration_value'];
        $unit = $input['duration_unit'];
        $allowedUnits = ['day', 'week', 'month', 'year'];
        if (!in_array($unit, $allowedUnits, true) || $value <= 0 || $value > 3650) {
            jsonResponse(false, null, 'مدة أو وحدة الاشتراك غير صحيحة');
        }

        $stmt = $db->prepare("SELECT id, role FROM `users` WHERE id = ?");
        $stmt->execute([$targetId]);
        $target = $stmt->fetch();
        if (!$target || $target['role'] !== 'user') {
            jsonResponse(false, null, 'المستخدم غير موجود');
        }

        $startDateObj = new DateTimeImmutable('today');
        $modifier = '+' . $value . ' ' . $unit;
        $endDate = $startDateObj->modify($modifier)->format('Y-m-d');
        $startDate = $startDateObj->format('Y-m-d');

        $db->prepare("INSERT INTO `subscriptions` (user_id, duration_value, duration_unit, start_date, end_date, status, created_by)
                      VALUES (?, ?, ?, ?, ?, 'active', ?)")
           ->execute([$targetId, $value, $unit, $startDate, $endDate, $admin['id']]);

        $db->prepare("UPDATE `users` SET subscription_status = 'active' WHERE id = ?")->execute([$targetId]);

        jsonResponse(true, ['end_date' => $endDate], 'تم تفعيل الاشتراك بنجاح');
    }

    if ($action === 'cancel_subscription') {
        if (empty($input['user_id'])) {
            jsonResponse(false, null, 'معرف المستخدم مطلوب');
        }
        $targetId = (int)$input['user_id'];

        $db->prepare("UPDATE `subscriptions` SET status = 'cancelled' WHERE user_id = ? AND status = 'active'")->execute([$targetId]);
        $db->prepare("UPDATE `users` SET subscription_status = 'cancelled' WHERE id = ?")->execute([$targetId]);

        jsonResponse(true, null, 'تم إلغاء الاشتراك بنجاح');
    }

    http_response_code(404);
    jsonResponse(false, null, 'إجراء غير معروف');
}

http_response_code(405);
jsonResponse(false, null, 'الطريقة غير مدعومة');

<?php
require_once 'config.php';

try {
    $user_id = getAuthUser();
    $db = getDB();
    $method = $_SERVER['REQUEST_METHOD'];
    $table = tbl('products');

    switch ($method) {

        case 'GET':
            if (isset($_GET['id'])) {
                $id = filter_var($_GET['id'], FILTER_VALIDATE_INT);
                if (!$id) {
                    http_response_code(400);
                    jsonResponse(false, null, 'معرف المادة غير صالح');
                }

                $stmt = $db->prepare("
                    SELECT id, name, cost_price, price, currency, notes, created_at, updated_at
                    FROM `{$table}`
                    WHERE id = ? AND user_id = ?
                    LIMIT 1
                ");
                $stmt->execute([$id, $user_id]);
                $product = $stmt->fetch();

                if (!$product) {
                    http_response_code(404);
                    jsonResponse(false, null, 'المادة غير موجودة');
                }

                jsonResponse(true, $product);
            }

            $stmt = $db->prepare("
                SELECT id, name, cost_price, price, currency, notes, created_at, updated_at
                FROM `{$table}`
                WHERE user_id = ?
                ORDER BY created_at DESC, id DESC
            ");
            $stmt->execute([$user_id]);

            jsonResponse(true, $stmt->fetchAll());
            break;

        case 'POST':
            $input = getInput();

            $name = trim((string)($input['name'] ?? ''));
            $currency = strtoupper(trim((string)($input['currency'] ?? '')));
            $price = $input['price'] ?? null;
            $costPrice = $input['cost_price'] ?? 0;
            $notes = isset($input['notes']) ? trim((string)$input['notes']) : null;

            if ($name === '') {
                http_response_code(400);
                jsonResponse(false, null, 'اسم المادة مطلوب');
            }

            if ($price === null || $price === '' || !is_numeric($price) || (float)$price < 0) {
                http_response_code(400);
                jsonResponse(false, null, 'سعر البيع غير صالح');
            }

            if (!is_numeric($costPrice) || (float)$costPrice < 0) {
                http_response_code(400);
                jsonResponse(false, null, 'سعر الشراء غير صالح');
            }

            if (!in_array($currency, ['USD', 'LOCAL'], true)) {
                http_response_code(400);
                jsonResponse(false, null, 'العملة غير صالحة');
            }

            $stmt = $db->prepare("
                INSERT INTO `{$table}` (user_id, name, cost_price, price, currency, notes)
                VALUES (?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $user_id,
                $name,
                (float)$costPrice,
                (float)$price,
                $currency,
                $notes !== '' ? $notes : null
            ]);

            $id = (int)$db->lastInsertId();

            // إعادة المادة كاملة حتى يستطيع الواجهة استخدامها مباشرة.
            $stmt = $db->prepare("
                SELECT id, name, cost_price, price, currency, notes, created_at, updated_at
                FROM `{$table}`
                WHERE id = ? AND user_id = ?
                LIMIT 1
            ");
            $stmt->execute([$id, $user_id]);

            jsonResponse(true, $stmt->fetch(), 'تمت إضافة المادة بنجاح');
            break;

        case 'PUT':
            $input = getInput();

            $id = filter_var($input['id'] ?? null, FILTER_VALIDATE_INT);
            $name = trim((string)($input['name'] ?? ''));
            $currency = strtoupper(trim((string)($input['currency'] ?? '')));
            $price = $input['price'] ?? null;
            $costPrice = $input['cost_price'] ?? 0;
            $notes = isset($input['notes']) ? trim((string)$input['notes']) : null;

            if (!$id) {
                http_response_code(400);
                jsonResponse(false, null, 'معرف المادة مطلوب');
            }

            if ($name === '') {
                http_response_code(400);
                jsonResponse(false, null, 'اسم المادة مطلوب');
            }

            if ($price === null || $price === '' || !is_numeric($price) || (float)$price < 0) {
                http_response_code(400);
                jsonResponse(false, null, 'سعر البيع غير صالح');
            }

            if (!is_numeric($costPrice) || (float)$costPrice < 0) {
                http_response_code(400);
                jsonResponse(false, null, 'سعر الشراء غير صالح');
            }

            if (!in_array($currency, ['USD', 'LOCAL'], true)) {
                http_response_code(400);
                jsonResponse(false, null, 'العملة غير صالحة');
            }

            // نتأكد أولاً أن المادة تخص المستخدم الحالي.
            $stmt = $db->prepare("SELECT id FROM `{$table}` WHERE id = ? AND user_id = ? LIMIT 1");
            $stmt->execute([$id, $user_id]);
            if (!$stmt->fetch()) {
                http_response_code(404);
                jsonResponse(false, null, 'المادة غير موجودة أو لا تملك صلاحية تعديلها');
            }

            $stmt = $db->prepare("
                UPDATE `{$table}`
                SET name = ?, cost_price = ?, price = ?, currency = ?, notes = ?
                WHERE id = ? AND user_id = ?
            ");
            $stmt->execute([
                $name,
                (float)$costPrice,
                (float)$price,
                $currency,
                $notes !== '' ? $notes : null,
                $id,
                $user_id
            ]);

            $stmt = $db->prepare("
                SELECT id, name, cost_price, price, currency, notes, created_at, updated_at
                FROM `{$table}`
                WHERE id = ? AND user_id = ?
                LIMIT 1
            ");
            $stmt->execute([$id, $user_id]);

            jsonResponse(true, $stmt->fetch(), 'تم تحديث المادة بنجاح');
            break;

        case 'DELETE':
            $id = filter_var($_GET['id'] ?? null, FILTER_VALIDATE_INT);

            if (!$id) {
                http_response_code(400);
                jsonResponse(false, null, 'معرف المادة غير صالح');
            }

            // تحقق من الملكية قبل الحذف.
            $stmt = $db->prepare("SELECT id FROM `{$table}` WHERE id = ? AND user_id = ? LIMIT 1");
            $stmt->execute([$id, $user_id]);
            if (!$stmt->fetch()) {
                http_response_code(404);
                jsonResponse(false, null, 'المادة غير موجودة أو لا تملك صلاحية حذفها');
            }

            try {
                $stmt = $db->prepare("DELETE FROM `{$table}` WHERE id = ? AND user_id = ?");
                $stmt->execute([$id, $user_id]);
            } catch (PDOException $e) {
                // sales.product_id يستخدم ON DELETE RESTRICT، لذلك لا نحذف مادة مرتبطة بمبيعات.
                if ((string)$e->getCode() === '23000') {
                    http_response_code(409);
                    jsonResponse(false, null, 'لا يمكن حذف المادة لأنها مرتبطة بعملية بيع سابقة. يمكنك تعديلها بدلاً من حذفها.');
                }
                throw $e;
            }

            jsonResponse(true, ['id' => $id], 'تم حذف المادة بنجاح');
            break;

        default:
            http_response_code(405);
            header('Allow: GET, POST, PUT, DELETE, OPTIONS');
            jsonResponse(false, null, 'الطريقة غير مدعومة');
    }

} catch (Throwable $e) {
    // لا نعرض تفاصيل أخطاء PHP الداخلية للمستخدم.
    error_log('products.php: ' . $e->getMessage());

    if (http_response_code() < 400) {
        http_response_code(500);
    }

    jsonResponse(false, null, 'حدث خطأ في معالجة المواد، يرجى المحاولة مرة أخرى');
}

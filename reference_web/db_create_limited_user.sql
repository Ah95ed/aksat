-- ============================================
-- إنشاء مستخدم قاعدة بيانات محدود الصلاحيات لتطبيق aksat
-- نفّذ هذا في phpMyAdmin أو عبر سطر أوامر MySQL على Hostinger
-- ============================================

-- 1) أنشئ المستخدم (غيّر كلمة المرور إلى قيمة قوية خاصة بك)
CREATE USER IF NOT EXISTS 'aksat_maadnowaksat'@'localhost' IDENTIFIED BY 'CHANGE_ME_DATABASE_PASSWORD';

-- 2) امنحه فقط الصلاحيات التي يحتاجها التطبيق على قاعدة بياناته
--    (بدون GRANT OPTION, بدون DROP/ALTER على مستوى القاعدة, بدون صلاحيات إدارية)
GRANT SELECT, INSERT, UPDATE, DELETE ON `aksat_aksatmaadmaad`.* TO 'aksat_maadnowaksat'@'localhost';

-- إن كان التطبيق يحتاج إنشاء/تعديل جداول أثناء الإعداد الأولي (Setup.vue) فقط،
-- امنح هذه الصلاحيات مؤقتاً أثناء التنصيب ثم أزلها بعد الانتهاء:
-- GRANT CREATE, ALTER, INDEX ON `aksat_aksatmaadmaad`.* TO 'aksat_maadnowaksat'@'localhost';
-- (بعد التنصيب: REVOKE CREATE, ALTER, INDEX ON `aksat_aksatmaadmaad`.* FROM 'aksat_maadnowaksat'@'localhost';)

FLUSH PRIVILEGES;

-- 3) تحقق من الصلاحيات الممنوحة
SHOW GRANTS FOR 'aksat_maadnowaksat'@'localhost';

-- ============================================
-- ملاحظات:
-- - على استضافة Hostinger عادة اسم المستخدم يُسبق تلقائياً باسم القاعدة
--   (مثال: u123456789_aksat_maadnowaksat) — استخدم الاسم الفعلي الذي يولّده لوحة التحكم.
-- - بعد إنشاء المستخدم، حدّث DB_USER و DB_PASS في api/config.php لتطابق
--   هذا المستخدم بدلاً من root.
-- - لا تستخدم مستخدم root للتطبيق أبداً؛ هذا المستخدم المحدود يمنع أن يتمكن
--   أي كود مخترق (SQL injection مثلاً) من حذف/تعديل قواعد بيانات أخرى على الخادم.
-- ============================================

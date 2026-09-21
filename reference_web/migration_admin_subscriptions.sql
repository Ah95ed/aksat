-- ============================================
-- ترقية قاعدة البيانات: نظام الإدارة والاشتراكات
-- نفّذ هذا الملف مرة واحدة فقط على قاعدة البيانات aksat_aksatmaadmaad
-- ============================================

-- 1) حالة الاشتراك المختصرة على جدول المستخدمين (لتسريع الفحص عند كل طلب)
ALTER TABLE `users`
  ADD COLUMN `subscription_status` ENUM('active','cancelled','expired') NOT NULL DEFAULT 'active' AFTER `role`;

-- 2) جدول الاشتراكات (سجل كامل لكل فترة اشتراك)
CREATE TABLE IF NOT EXISTS `subscriptions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `duration_value` INT NOT NULL,
  `duration_unit` ENUM('day','week','month','year') NOT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `status` ENUM('active','cancelled','expired') NOT NULL DEFAULT 'active',
  `created_by` INT DEFAULT NULL,
  `notes` TEXT COLLATE utf8mb4_unicode_ci,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `subscriptions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `subscriptions_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3) لا يتم تعيين الأدمن تلقائياً هنا. أنشئ الحساب أولاً ثم اجعل الحساب
-- الإداري Admin من خلال أداة إدارة قاعدة البيانات/SQL الخاصة بك.

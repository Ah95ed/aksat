# نظام إدارة البيع بالتقسيط

نظام Vue/Vite + PHP/MySQL لإدارة المواد والمخزون والمشترين والمبيعات والأقساط والتقارير والاشتراكات.

## البنية الحالية

- الواجهة: Vue 3 + Vite + Tailwind
- API: PHP
- قاعدة البيانات: MySQL/MariaDB
- المصادقة: JWT (HS256)
- عزل البيانات: كل سجل تجاري مرتبط بـ `user_id`
- إدارة الاشتراكات والأدمن من خلال `api/admin.php`

> النسخة الحالية لا تستخدم نظام PREFIX القديم. جميع جداول التطبيق مشتركة، وعزل بيانات المستخدمين يتم عبر `user_id`.

## التطوير المحلي

```bash
npm install
npm run dev
```

لتثبيت مكتبة PHP:

```bash
composer install --no-dev --optimize-autoloader
```

ولإنشاء نسخة الإنتاج:

```bash
npm run build
```

## النشر على Hostinger

1. أنشئ قاعدة البيانات ومستخدم MySQL من hPanel.
2. استورد مخطط قاعدة البيانات الأساسي، ثم `migration_admin_subscriptions.sql` إذا لم تكن ترقية الاشتراكات قد نُفذت.
3. عدّل `api/config.local.php` وضع كلمة مرور قاعدة البيانات الفعلية.
4. شغّل `composer install --no-dev --optimize-autoloader` على السيرفر إذا لم يكن مجلد `vendor` موجوداً.
5. ارفع محتويات `dist/` إلى جذر الموقع، وارفع مجلد `api/` ومجلد `vendor/` في المكان المتوقع من `api/config.php`.
6. تأكد من HTTPS.
7. لا تضع `api/config.local.php` أو ملفات SQL/Composer في GitHub.

### بيانات قاعدة البيانات لهذه النسخة

- Database: `aksat_aksatmaadmaad`
- User: `aksat_maadnowaksat`
- Password: توضع في `api/config.local.php` ولا تُكتب في المستودع.

## الأمان

- Prepared statements في عمليات قاعدة البيانات.
- التحقق من `user_id` في عمليات القراءة والتعديل والحذف.
- كلمات المرور باستخدام `password_hash` و`password_verify`.
- JWT مع مفتاح منفصل لكل تثبيت.
- Rate limiting لتسجيل الدخول والتسجيل.
- رسائل الأخطاء العامة للمستخدم، مع تسجيل التفاصيل في سجل السيرفر.
- CORS مقيد بالدومين المسموح.
- Security headers وHSTS عند استخدام HTTPS.
- مستخدم MySQL محدود الصلاحيات بدلاً من root.

## ملاحظات مهمة

- لا تستخدم `db_create_limited_user.sql` حرفياً قبل التأكد من كلمة مرور المستخدم الفعلية التي أنشأتها Hostinger.
- يفضّل عدم حذف المبيعات نهائياً في نظام محاسبي تجاري؛ الأفضل لاحقاً إضافة حالة `cancelled` وسجل تدقيق Audit Log.
- يجب إنشاء نسخة احتياطية دورية لقاعدة البيانات.

# Security Audit - Aksat

## Result
The project was reviewed statically file-by-file across the PHP API and Vue frontend.
PHP syntax checks pass for all API files.

## Fixed in this package
- Removed hardcoded JWT secret from `api/config.php`; secret is now loaded from `api/config.local.php` or environment variable `AKSAT_JWT_SECRET`.
- Configured database name/user for the target Hostinger installation.
- Added protection for `config.local.php` and sensitive files via `.htaccess`.
- Removed obsolete `/setup` route because `api/setup.php` is not present in this version.
- Removed obsolete PREFIX deployment logic and updated README/deployment instructions.
- Stopped exposing database/PHP exception messages to users; details go to server logs.
- Login IP rate limiting no longer trusts spoofable `X-Forwarded-For`.
- Added registration request rate limiting.
- Made login/register JWT lifetime consistent at 24 hours.
- Added stronger validation for sale amounts, quantity, installment count/type, currency, and sale date.
- Added row locking for inventory lookup during a sale to reduce concurrent stock races.
- Added validation for installment IDs/actions/payment date.
- Added whitelist and validation for settings keys/values.
- Removed the hardcoded personal admin email from the subscription migration.
- Added `.gitignore` so local secrets are not accidentally committed.

## Remaining recommendations before commercial launch
1. Use a unique JWT secret per installation/client.
2. Keep `api/config.local.php` outside GitHub; use environment variables if Hostinger setup permits.
3. Prefer HttpOnly/Secure/SameSite cookies over localStorage for long-term authentication hardening.
4. Add an Audit Log for financial/admin actions.
5. Prefer cancelling sales (`cancelled`) over hard deletion once the system is used for accounting.
6. Add database UNIQUE constraints and foreign keys/indexes according to the actual production schema.
7. Confirm the production database contains the complete base schema; this project archive does not include the original base schema SQL or `setup.php`.
8. Install PHP dependencies on the server with `composer install --no-dev --optimize-autoloader` if `vendor/` is not already deployed.
9. Build the Vue frontend with `npm run build` and upload the contents of `dist/`.
10. Enable HTTPS and keep backups of the database.

## Important
The database password was not supplied, so `api/config.local.php` contains a placeholder `CHANGE_ME_DATABASE_PASSWORD`. Replace it before production use.

@echo off
setlocal
call npm run build
if errorlevel 1 exit /b 1
echo Build complete. Upload dist contents plus api folder to Hostinger.
echo IMPORTANT: set DB_PASS in api\config.local.php before uploading.
pause

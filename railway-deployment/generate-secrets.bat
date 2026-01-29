@echo off
REM Quick Secret Generation Script for Railway Deployment (Windows)

echo 🔐 Generating secrets for Railway deployment...
echo.
echo ================================================
echo COPY THESE VALUES TO YOUR RAILWAY ENVIRONMENT VARIABLES
echo ================================================
echo.

echo Generating REGISTRATION_SHARED_SECRET...
powershell -Command "$bytes = New-Object byte[] 32; (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes); Write-Host 'REGISTRATION_SHARED_SECRET='([System.BitConverter]::ToString($bytes) -replace '-').ToLower()"

echo Generating MACAROON_SECRET_KEY...
powershell -Command "$bytes = New-Object byte[] 32; (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes); Write-Host 'MACAROON_SECRET_KEY='([System.BitConverter]::ToString($bytes) -replace '-').ToLower()"

echo Generating FORM_SECRET...
powershell -Command "$bytes = New-Object byte[] 32; (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes); Write-Host 'FORM_SECRET='([System.BitConverter]::ToString($bytes) -replace '-').ToLower()"

echo Generating MAS_ENCRYPTION_SECRET...
powershell -Command "$bytes = New-Object byte[] 32; (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes); Write-Host 'MAS_ENCRYPTION_SECRET='([System.BitConverter]::ToString($bytes) -replace '-').ToLower()"

echo Generating MAS_SIGNING_KEY...
powershell -Command "$bytes = New-Object byte[] 32; (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes); Write-Host 'MAS_SIGNING_KEY='([System.BitConverter]::ToString($bytes) -replace '-').ToLower()"

echo.
echo ================================================
echo ✅ Secrets generated successfully!
echo.
echo Next steps:
echo 1. Copy the values above
echo 2. Go to your Railway project
echo 3. Add these as environment variables to the respective services
echo 4. Deploy your services
echo.
pause

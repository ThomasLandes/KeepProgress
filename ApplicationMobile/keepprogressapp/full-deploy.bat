@echo off
echo ========================================
echo    KEEPPROGRESS API - DEPLOIEMENT COMPLET
echo ========================================
echo.

REM Configuration
set SSH_KEY=C:\Users\tsuyo\Downloads\ssh-key-2025-04-18.key
set VPS_USER=mateus
set VPS_IP=84.235.238.246
set VPS_PATH=/var/www/html/keepprogress_api
set LOCAL_PATH=C:\Users\tsuyo\Desktop\KeepProgress\ApplicationMobile\keepprogressapp\api

echo [ETAPE 1/3] Preparation du repertoire distant...
ssh -i "%SSH_KEY%" %VPS_USER%@%VPS_IP% "mkdir -p %VPS_PATH%"
ssh -i "%SSH_KEY%" %VPS_USER%@%VPS_IP% "rm -rf %VPS_PATH%/*"

echo [ETAPE 2/3] Upload des fichiers API et database...
scp -i "%SSH_KEY%" -r "%LOCAL_PATH%/*" %VPS_USER%@%VPS_IP%:%VPS_PATH%/
scp -i "%SSH_KEY%" "database.sql" %VPS_USER%@%VPS_IP%:/tmp/
if %errorlevel% neq 0 (
    echo ERREUR: Echec de l'upload des fichiers
    pause
    exit /b 1
)

echo [ETAPE 3/3] Verification du deploiement...
echo.
echo --- Structure des fichiers ---
ssh -i "%SSH_KEY%" %VPS_USER%@%VPS_IP% "ls -la %VPS_PATH%/"
echo.
echo --- Fichiers PHP deploys ---
ssh -i "%SSH_KEY%" %VPS_USER%@%VPS_IP% "find %VPS_PATH% -name '*.php' -type f | wc -l" 2>nul
ssh -i "%SSH_KEY%" %VPS_USER%@%VPS_IP% "find %VPS_PATH% -name '*.php' -type f"
echo.
echo --- Test de connectivite API ---
ssh -i "%SSH_KEY%" %VPS_USER%@%VPS_IP% "curl -s -o /dev/null -w 'Code HTTP: %%{http_code}' http://localhost/keepprogress_api/auth/login.php"
echo.
echo.

echo ========================================
echo    DEPLOIEMENT TERMINE !
echo ========================================
echo.
echo API disponible sur: http://%VPS_IP%/keepprogress_api/
echo.
echo Pour configurer la base de donnees, connecte-toi au VPS et execute:
echo sudo mysql -u root ^< /tmp/database.sql
echo.
pause

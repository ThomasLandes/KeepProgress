@echo off
echo [INFO] Mise a jour rapide de l'API...

set SSH_KEY=C:\Users\tsuyo\Downloads\ssh-key-2025-04-18.key
set VPS_USER=mateus
set VPS_IP=84.235.238.246
set VPS_PATH=/var/www/html/keepprogress_api
set LOCAL_PATH=C:\Users\tsuyo\Desktop\KeepProgress\ApplicationMobile\keepprogressapp\api

scp -i "%SSH_KEY%" -r "%LOCAL_PATH%/*" %VPS_USER%@%VPS_IP%:%VPS_PATH%/

echo [INFO] Verification des fichiers deployes...
ssh -i "%SSH_KEY%" %VPS_USER%@%VPS_IP% "ls -la %VPS_PATH%/"
echo.
echo [INFO] Structure de l'API:
ssh -i "%SSH_KEY%" %VPS_USER%@%VPS_IP% "find %VPS_PATH% -type f -name '*.php' | head -10"

echo [OK] Mise a jour terminee !
timeout /t 3

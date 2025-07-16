@echo off
echo ========================================
echo    CONNEXION SSH AU VPS KEEPPROGRESS
echo ========================================
echo.
echo Connexion vers: mateus@84.235.238.246
echo.

REM Connexion SSH directe avec la clé privée
ssh -i "C:\Users\tsuyo\Downloads\ssh-key-2025-04-18.key" mateus@84.235.238.246

echo.
echo Connexion fermee.
pause

@echo off
setlocal enabledelayedexpansion
echo ========================================
echo    KEEPPROGRESS API - TESTS COMPLETS
echo ========================================
echo.

REM Configuration
set API_URL=http://84.235.238.246/keepprogress_api
set TEST_EMAIL=test_%RANDOM%@example.com
set TEST_PASSWORD=TestPassword123
set TEST_NAME=Test User
set TEST_AGE=25

echo Configuration des tests:
echo - API URL: %API_URL%
echo - Email de test: %TEST_EMAIL%
echo - Mot de passe: %TEST_PASSWORD%
echo.

REM Variables pour stocker les résultats
set USER_TOKEN=
set USER_ID=
set TEST_PASSED=0
set TEST_FAILED=0

echo ========================================
echo           DEBUT DES TESTS
echo ========================================
echo.

REM TEST 1: Vérification de la connectivité du serveur
echo [TEST 1/6] Test de connectivite du serveur...
powershell -Command "try { $response = Invoke-WebRequest -Uri '%API_URL%/auth/login.php' -Method POST -ContentType 'application/json' -Body '{\"email\":\"fake\",\"password\":\"fake\"}' -ErrorAction SilentlyContinue; if($response.StatusCode -eq 405 -or $response.StatusCode -eq 400) { Write-Host '[OK] Serveur accessible (Code:' $response.StatusCode ')'; exit 0 } else { Write-Host '[ERREUR] Code inattendu:' $response.StatusCode; exit 1 } } catch { if($_.Exception.Response.StatusCode.Value__ -eq 405 -or $_.Exception.Response.StatusCode.Value__ -eq 400) { Write-Host '[OK] Serveur accessible'; exit 0 } else { Write-Host '[ERREUR] Serveur inaccessible:' $_.Exception.Message; exit 1 } }"
if !errorlevel! equ 0 (
    set /a TEST_PASSED+=1
    echo.
) else (
    set /a TEST_FAILED+=1
    echo.
)

REM TEST 2: Inscription d'un nouvel utilisateur
echo [TEST 2/6] Test d'inscription d'un nouvel utilisateur...
powershell -Command "$body = @{ nom='%TEST_NAME%'; age=%TEST_AGE%; email='%TEST_EMAIL%'; password='%TEST_PASSWORD%' } | ConvertTo-Json; try { $response = Invoke-WebRequest -Uri '%API_URL%/auth/register.php' -Method POST -ContentType 'application/json' -Body $body; $result = $response.Content | ConvertFrom-Json; if($result.success) { Write-Host '[OK] Inscription reussie:' $result.message; Write-Host 'USER_ID=' $result.user.id; Write-Host 'TOKEN=' $result.token.Substring(0,30)...; exit 0 } else { Write-Host '[ERREUR] Inscription echouee:' $result.message; exit 1 } } catch { Write-Host '[ERREUR] Erreur inscription:' $_.Exception.Message; exit 1 }" > temp_register.txt
type temp_register.txt
findstr "USER_ID=" temp_register.txt > nul
if !errorlevel! equ 0 (
    for /f "tokens=2" %%i in ('findstr "USER_ID=" temp_register.txt') do set USER_ID=%%i
    set /a TEST_PASSED+=1
) else (
    set /a TEST_FAILED+=1
)
del temp_register.txt 2>nul
echo.

REM TEST 3: Connexion avec le nouvel utilisateur
echo [TEST 3/6] Test de connexion avec le nouvel utilisateur...
powershell -Command "$body = @{ email='%TEST_EMAIL%'; password='%TEST_PASSWORD%' } | ConvertTo-Json; try { $response = Invoke-WebRequest -Uri '%API_URL%/auth/login.php' -Method POST -ContentType 'application/json' -Body $body; $result = $response.Content | ConvertFrom-Json; if($result.success) { Write-Host '[OK] Connexion reussie:' $result.message; Write-Host 'TOKEN=' $result.token; exit 0 } else { Write-Host '[ERREUR] Connexion echouee:' $result.message; exit 1 } } catch { Write-Host '[ERREUR] Erreur connexion:' $_.Exception.Message; exit 1 }" > temp_login.txt
type temp_login.txt
findstr "TOKEN=" temp_login.txt > nul
if !errorlevel! equ 0 (
    for /f "tokens=2" %%i in ('findstr "TOKEN=" temp_login.txt') do set USER_TOKEN=%%i
    set /a TEST_PASSED+=1
) else (
    set /a TEST_FAILED+=1
)
del temp_login.txt 2>nul
echo.

REM TEST 4: Récupération du profil utilisateur
echo [TEST 4/6] Test de recuperation du profil utilisateur...
if defined USER_TOKEN (
    powershell -Command "$headers = @{ 'Authorization' = 'Bearer %USER_TOKEN%'; 'Content-Type' = 'application/json' }; try { $response = Invoke-WebRequest -Uri '%API_URL%/user/profile.php' -Method GET -Headers $headers; $result = $response.Content | ConvertFrom-Json; if($result.success) { Write-Host '[OK] Profil recupere:' $result.message; Write-Host 'Nom:' $result.data.user.nom; Write-Host 'Email:' $result.data.user.email; Write-Host 'Age:' $result.data.user.age; exit 0 } else { Write-Host '[ERREUR] Erreur profil:' $result.message; exit 1 } } catch { Write-Host '[ERREUR] Erreur requete profil:' $_.Exception.Message; exit 1 }"
    if !errorlevel! equ 0 (
        set /a TEST_PASSED+=1
    ) else (
        set /a TEST_FAILED+=1
    )
) else (
    echo [ERREUR] Pas de token disponible pour le test
    set /a TEST_FAILED+=1
)
echo.

REM TEST 5: Test de déconnexion
echo [TEST 5/6] Test de deconnexion...
if defined USER_TOKEN (
    powershell -Command "$headers = @{ 'Authorization' = 'Bearer %USER_TOKEN%'; 'Content-Type' = 'application/json' }; try { $response = Invoke-WebRequest -Uri '%API_URL%/auth/logout.php' -Method POST -Headers $headers; $result = $response.Content | ConvertFrom-Json; if($result.success) { Write-Host '[OK] Deconnexion reussie:' $result.message; exit 0 } else { Write-Host '[ERREUR] Deconnexion echouee:' $result.message; exit 1 } } catch { Write-Host '[ERREUR] Erreur deconnexion:' $_.Exception.Message; exit 1 }"
    if !errorlevel! equ 0 (
        set /a TEST_PASSED+=1
    ) else (
        set /a TEST_FAILED+=1
    )
) else (
    echo [ERREUR] Pas de token disponible pour le test
    set /a TEST_FAILED+=1
)
echo.

REM TEST 6: Test avec token invalide (sécurité)
echo [TEST 6/6] Test de securite avec token invalide...
powershell -Command "$headers = @{ 'Authorization' = 'Bearer invalid_token_123'; 'Content-Type' = 'application/json' }; try { $response = Invoke-WebRequest -Uri '%API_URL%/user/profile.php' -Method GET -Headers $headers; $result = $response.Content | ConvertFrom-Json; if($result.success -eq $false) { Write-Host '[OK] Token invalide correctement rejete:' $result.message; exit 0 } else { Write-Host '[ERREUR] Token invalide accepte (probleme de securite)'; exit 1 } } catch { if($_.Exception.Response.StatusCode.Value__ -eq 401) { Write-Host '[OK] Token invalide correctement rejete (401)'; exit 0 } else { Write-Host '[ERREUR] Erreur inattendue:' $_.Exception.Message; exit 1 } }"
if !errorlevel! equ 0 (
    set /a TEST_PASSED+=1
) else (
    set /a TEST_FAILED+=1
)
echo.

REM NETTOYAGE: Suppression de l'utilisateur de test
echo ========================================
echo            NETTOYAGE
echo ========================================
echo.
echo [NETTOYAGE] Suppression de l'utilisateur de test...
if defined USER_ID (
    ssh -i "C:\Users\tsuyo\Downloads\ssh-key-2025-04-18.key" mateus@84.235.238.246 "mysql -u keepuser -p'Keep31!' keepprogress_db -e 'DELETE FROM auth_tokens WHERE user_id=%USER_ID%; DELETE FROM users WHERE id=%USER_ID%;'" 2>nul
    if !errorlevel! equ 0 (
        echo [OK] Utilisateur de test supprime (ID: %USER_ID%)
    ) else (
        echo [ATTENTION] Erreur lors de la suppression de l'utilisateur
    )
) else (
    echo [INFO] Aucun utilisateur a supprimer
)
echo.

REM RÉSULTATS FINAUX
echo ========================================
echo         RESULTATS DES TESTS
echo ========================================
echo.
echo Tests reussis: %TEST_PASSED%/6
echo Tests echoues: %TEST_FAILED%/6
echo.

if %TEST_FAILED% equ 0 (
    echo [SUCCESS] Tous les tests sont passes! 🎉
    echo L'API fonctionne correctement.
) else (
    echo [WARNING] %TEST_FAILED% test(s) ont echoue.
    echo Verifiez la configuration de l'API et de la base de donnees.
)
echo.

echo ========================================
echo           TESTS TERMINES
echo ========================================
echo.
echo Endpoints testes:
echo - POST /auth/register.php
echo - POST /auth/login.php  
echo - GET  /user/profile.php
echo - POST /auth/logout.php
echo - Test de securite (token invalide)
echo.
pause

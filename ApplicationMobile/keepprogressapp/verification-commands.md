# Commandes pour vérifier le déploiement de l'API

## 1. Se connecter au VPS
ssh -i "C:\Users\tsuyo\Downloads\ssh-key-2025-04-18.key" mateus@84.235.238.246

## 2. Vérifier les fichiers déployés
ls -la /var/www/html/keepprogress_api/

## 3. Vérifier la structure complète
find /var/www/html/keepprogress_api/ -type f -name "*.php"

## 4. Vérifier les permissions
ls -la /var/www/html/keepprogress_api/auth/
ls -la /var/www/html/keepprogress_api/user/
ls -la /var/www/html/keepprogress_api/helpers/

## 5. Tester l'API localement sur le VPS
curl -X POST http://localhost/keepprogress_api/auth/login.php \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test"}'

## 6. Vérifier les logs Apache
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/log/apache2/access.log

## 7. Tester depuis l'extérieur (depuis ton PC)
curl -X POST http://84.235.238.246/keepprogress_api/auth/login.php \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test"}'

## 8. Vérifier que la base de données existe
mysql -u root -p -e "SHOW DATABASES;" | grep keepprogress

## 9. Vérifier les tables
mysql -u root -p keepprogress_api -e "SHOW TABLES;"

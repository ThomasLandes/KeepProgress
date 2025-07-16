# KeepProgress - Commentaires et Explications

## Structure du Projet

### Backend PHP (API)
- **config/database.php** - Configuration de la connexion à la base de données MySQL
- **helpers/TokenHelper.php** - Gestion des tokens d'authentification (génération, validation, stockage)
- **helpers/ResponseHelper.php** - Réponses API standardisées (succès, erreurs, validation)
- **middleware/AuthMiddleware.php** - Middleware pour vérifier l'authentification sur les endpoints protégés
- **auth/register.php** - Endpoint d'inscription des nouveaux utilisateurs
- **auth/login.php** - Endpoint de connexion des utilisateurs existants
- **auth/logout.php** - Endpoint de déconnexion (révocation du token)
- **user/profile.php** - Gestion du profil utilisateur (lecture/modification)
- **progress/index.php** - CRUD complet pour le suivi des progrès utilisateur

### Frontend Flutter (lib/)
- **services/session_manager.dart** - Gestion sécurisée des tokens avec flutter_secure_storage
- **services/api_service.dart** - Communication avec l'API backend (inscription, connexion, requêtes authentifiées)
- **pages/login_page.dart** - Interface de connexion utilisateur
- **pages/signup_page.dart** - Interface d'inscription utilisateur
- **pages/dashboard_page.dart** - Page d'accueil après connexion
- **models/user_model.dart** - Modèle de données utilisateur

## Flux d'Authentification

### 1. Inscription (register.php + signup_page.dart)
- L'utilisateur saisit nom, âge, email, mot de passe
- Validation côté client et serveur
- Hachage sécurisé du mot de passe (password_hash)
- Génération d'un token d'authentification
- Stockage sécurisé du token sur l'appareil

### 2. Connexion (login.php + login_page.dart)
- Vérification email/mot de passe avec la base de données
- Génération d'un nouveau token si les identifiants sont corrects
- Stockage sécurisé du token avec flutter_secure_storage

### 3. Authentification (AuthMiddleware.php + session_manager.dart)
- Chaque requête protégée vérifie la présence du token Bearer
- Validation de la signature et de l'expiration du token
- Récupération automatique des données utilisateur

### 4. Déconnexion (logout.php + api_service.dart)
- Révocation du token côté serveur
- Suppression du token stocké localement

## Sécurité Implémentée

### Côté Backend PHP
- **Requêtes préparées** - Protection contre l'injection SQL
- **Hachage des mots de passe** - Utilisation de password_hash() PHP
- **Tokens signés** - Validation HMAC pour éviter la falsification
- **Expiration des tokens** - Tokens valides 24h par défaut
- **Révocation des tokens** - Possibilité de révoquer les tokens
- **Validation des entrées** - Vérification de tous les champs utilisateur
- **En-têtes CORS** - Configuration pour les requêtes cross-origin

### Côté Frontend Flutter
- **Stockage sécurisé** - flutter_secure_storage utilise le Keychain iOS / Keystore Android
- **Chiffrement des tokens** - Les tokens ne sont jamais stockés en plain text
- **Validation côté client** - Vérification des formats email, longueur des mots de passe
- **Gestion des erreurs** - Affichage approprié des messages d'erreur

## Base de Données

### Tables Principales
- **users** - Données utilisateur (nom, âge, email, mot de passe haché)
- **auth_tokens** - Tokens d'authentification avec expiration
- **user_progress** - Suivi des progrès utilisateur (prêt pour fonctionnalités futures)

### Relations
- auth_tokens.user_id → users.id
- user_progress.user_id → users.id

## Configuration Requise

### Serveur VPS
1. PHP 7.4+ avec extensions PDO MySQL
2. MySQL/MariaDB
3. Serveur web (Apache/Nginx) avec mod_rewrite
4. HTTPS en production (recommandé)

### Application Flutter
1. Flutter SDK 3.8+
2. Packages: http, flutter_secure_storage, shared_preferences
3. Configuration des permissions pour le stockage sécurisé

## URLs d'API
- POST /auth/register.php - Inscription
- POST /auth/login.php - Connexion  
- POST /auth/logout.php - Déconnexion (nécessite token)
- GET/PUT /user/profile.php - Profil utilisateur (nécessite token)
- GET/POST/PUT/DELETE /progress/ - Gestion des progrès (nécessite token)

Toutes les réponses sont en JSON avec format standardisé:
```json
{
  "success": true/false,
  "message": "Message descriptif",
  "data": {...}, // Optionnel
  "token": "..." // Pour les authentifications
}
```

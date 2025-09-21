# KeepProgress — BackOffice (Laravel 11 + Filament v3)

Portail d’administration & API mobile pour KeepProgress (suivi sportif : exercices, séances, mensurations, repas…).

- **Framework** : Laravel 11 (PHP 8.2.12)
- **Admin** : Filament v3
- **Auth API** : Laravel Sanctum (Bearer tokens)
- **DB** : MySQL

## Sommaire
- [Aperçu rapide](#aperçu-rapide)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration (.env)](#configuration-env)
- [Base de données](#base-de-données)
- [Lancer en local](#lancer-en-local)
- [Accès BackOffice](#accès-backoffice)
- [API — Quick start](#api--quick-start)
- [Structure des tables](#structure-des-tables)
- [Sécurité](#sécurité)
- [Dépannage](#dépannage)
- [Crédits](#crédits)

---

## Aperçu rapide
- ✅ Auth Filament reliée à la table `users` (colonnes custom : `user_email` / `user_password`)
- ✅ CRUD **Users**, **Exercises**, **Training Sessions**, **Session Content**, **Gyms** (Filament)
- ✅ API protégée (Sanctum) : login/logout, `/exercises`, `/training-sessions`, `/session-content`, `/me`

---

## Prérequis
- PHP **8.2+**
- Composer
- MySQL **8.x**
- (Optionnel) Node.js si compilation d’assets (Filament fonctionne sans)

---

## Installation
```bash
git clone https://github.com/ThomasLandes/KeepProgress.git
cd BackOffice
composer install
cp .env.example .env
php artisan key:generate
```

---

## Configuration (.env)
Éditer `.env` :
```env
APP_NAME=KeepProgress
APP_ENV=local
APP_KEY=base64:xxxxx
APP_URL=http://127.0.0.1:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=keepprogress
DB_USERNAME=youruser
DB_PASSWORD=yourpass
```

---

## Base de données
Exécuter les migrations (incluant Sanctum) :
```bash
php artisan migrate
```

### Créer un admin rapidement (Tinker)
```bash
php artisan tinker
```
```php
use App\Models\User;
use Illuminate\Support\Facades\Hash;

User::create([
  'user_name' => 'Admin',
  'user_email' => 'admin@test.local',
  'user_password' => Hash::make('Admin123!'),
  'isAdmin' => true,
]);
```

---

## Lancer en local
```bash
php artisan serve
# http://127.0.0.1:8000
```

---

## Accès BackOffice
- URL du panel Filament : `http://127.0.0.1:8000/admin` *(par défaut, ajuster si différent)*  
- Seuls les utilisateurs avec `isAdmin = true` y accèdent.

**Important (User model)**  
Le modèle `User` mappe les colonnes custom :
```php
public function getAuthPasswordName(): string { return 'user_password'; }
public function getAuthPassword(): string { return $this->user_password; }
```

---

## API — Quick start
**Auth** : Bearer Token (Sanctum)  
Toutes les routes sensibles sont dans `routes/api.php` avec `auth:sanctum`.

### 1) Login
```
POST /api/login
Body: { "email": "user@test.com", "password": "MotDePasse" }
```
Réponse : `{ token, token_type, user }`

> Utiliser ensuite `Authorization: Bearer <token>` sur chaque requête protégée.

### 2) Exercices
```
GET /api/exercises
```
Retourne : `exercise_id, exercise_name, exercise_body_part, exercise_description, updated_at`

### 3) Sessions (utilisateur connecté)
```
GET  /api/training-sessions
POST /api/training-sessions  { "session_date": "YYYY-MM-DD HH:MM:SS", "duration": 60 }
```

### 4) Contenu d’une session
```
GET  /api/session-content?training_session_id=<id>
POST /api/session-content { "training_session_id": 7, "exercise_id": 2, "sets": 4, "reps": 10, "weight": 60 }
```

### 5) Profil & logout
```
GET  /api/me
POST /api/logout
```

> Une doc détaillée avec exemples cURL/Postman est fournie dans **`docs/API.md`**.

---

## Structure des tables
- **users**: `user_id`, `user_name`, `user_email` (unique), `user_password`, `isAdmin`, timestamps  
- **exercises**: `exercise_id`, `exercise_name`, `exercise_body_part`, `exercise_description`, timestamps  
- **training_sessions**: `training_session_id`, `user_id`, `session_date` (datetime), `duration` (int), timestamps  
- **session_content**: `session_content_id`, `training_session_id`, `exercise_id`, `sets`, `reps`, `weight`, timestamps  
- **gyms**: `gym_id`, `gym_name`, `gym_address`, `current_occupation`, `max_person_capacity`, `opening_hour`, `closing_hour`, timestamps

---

## Sécurité
- **HTTPS** en production (obligatoire)
- **Sanctum** : tokens personnels, stockage sécurisé côté mobile
- **Rate limiting** sur `/api/login` (par défaut `throttle:60,1`)
- (Optionnel) TTL token : ajouter `expires_at` sur `personal_access_tokens` + middleware

---

## Dépannage
- **404 sur `/api/*`**  
  Vérifier `bootstrap/app.php` :
  ```php
  ->withRouting(web: __DIR__.'/../routes/web.php', api: __DIR__.'/../routes/api.php', ...)
  ```
- **Update vers `password` au login**  
  Vérifier `User::getAuthPasswordName()` retourne `'user_password'`.
- **Hash invalide / rehash**  
  Générer via `Hash::make()` (produit `$2y$...`). Aligner `config/hashing.php` si besoin.
- **FK sessions**  
  Créer des users avant de créer des `training_sessions`.

Caches :
```bash
php artisan optimize:clear
```

---

## Crédits
- Laravel, Filament, Sanctum ❤️

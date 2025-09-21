# KeepProgress — Architecture & Choix techniques

## Objectif
Back-office d’administration + API mobile pour le suivi sportif (exercices, séances, contenus de séance, salles…).

## Vue d’ensemble
- **Laravel 11 (PHP 8.2)** : cœur applicatif, routes, ORM Eloquent, validation, middlewares.
- **Filament v3** : panneau d’admin (CRUD graphiques sur les tables principales).
- **Sanctum** : authentification **par Token Bearer** pour l’app mobile.
- **MySQL** : persistance des données (migrations versionnées).
- **Conventions de colonnes custom** : `user_id`, `user_email`, `user_password`, etc.

```
App mobile ──(HTTPS JSON, Bearer Token)──> API Laravel ──> Eloquent ──> MySQL
                                   ↑
                        Login / Token (Sanctum)
```

## Modèle de données (extrait)
- **users**: `user_id`, `user_name`, `user_email` (unique), `user_password`, `isAdmin`
- **exercises**: `exercise_id`, `exercise_name`, `exercise_body_part`, `exercise_description`
- **training_sessions**: `training_session_id`, `user_id`, `session_date` (datetime), `duration` (int)
- **session_content**: `session_content_id`, `training_session_id`, `exercise_id`, `sets`, `reps`, `weight`
- **gyms**: `gym_id`, `gym_name`, `gym_address`, `current_occupation`, `max_person_capacity`, `opening_hour`, `closing_hour`

### Relations clés
- `TrainingSession` **appartient à** `User` (FK: `user_id`).
- `SessionContent` **appartient à** `TrainingSession` et à `Exercise`.
- L’app mobile **lit/écrit** ses données via l’API protégée par Sanctum.

## Authentification & sécurité (Sanctum)
- **Login** `POST /api/login` :
  - Vérifie `user_email` + `user_password` (hash bcrypt `$2y$`).
  - Crée un **Personal Access Token** (PAT) avec `user->createToken(...)`.
  - Retourne `{ token, user }`.
- **Requêtes protégées** :
  - Header `Authorization: Bearer <token>`.
  - Middleware `auth:sanctum` vérifie et hydrate `Request->user()`.
- **Logout** : suppression du token courant, ou de tous les tokens.
- **Scopes/Abilities** (extensible) : possibilité de restreindre par capacités (ex: `exercises:read`).

**User model (points durs)**  
Mapping des colonnes custom pour éviter les updates sur `password` :
```php
public function getAuthPasswordName(): string { return 'user_password'; }
public function getAuthPassword(): string { return $this->user_password; }
```
Provider `auth` pointe sur `App\Models\User` (config/auth.php).

## Choix techniques
- **Sanctum vs Passport/JWT** : Sanctum choisi pour sa simplicité (app 1st‑party). Passport/JWT possible si besoin de refresh tokens & clients tiers.
- **Filament** : productivité élevée pour CRUD admin, filtres, relations (RelationManagers) et ergonomie.
- **Migrations** : versionnent la BDD; alters dédiés pour renommer/ajouter colonnes sans DBAL.
- **Validation** : `Request::validate()` (closures) ou **FormRequests** si factorisation souhaitée.
- **Sécurité** :
  - HTTPS obligatoire en prod.
  - `throttle` sur `/api/login`.
  - Stockage token côté mobile dans un espace **sécurisé** (EncryptedSharedPreferences / Keychain).
  - Option TTL token via champ `expires_at` + middleware.

## Flux de base

### 1) Connexion & token
```
App → POST /api/login { email, password }
API → vérifie hash, crée token Sanctum, renvoie token
App → stocke token sécurisé → l’ajoute au header Authorization sur chaque requête
```

### 2) Lecture des exercices
```
App → GET /api/exercises (Authorization: Bearer …)
API → retourne la liste (id, name, body_part, description, updated_at)
```

### 3) Gestion des séances
```
App → GET /api/training-sessions
API → renvoie uniquement les séances du user authentifié

App → POST /api/training-sessions { session_date, duration }
API → crée la séance pour user_id = Request->user()->user_id

App → GET /api/session-content?training_session_id=<id>
API → vérifie que la session appartient au user → retourne les lignes
```

## Structure du code (extrait)
- `app/Models/*` : modèles Eloquent (`$table`, `$primaryKey`, `$fillable`, relations).
- `app/Filament/Resources/*` : CRUD admin (forms/tables/pages, RelationManagers).
- `routes/api.php` : endpoints API (login, me, exercises, training-sessions, session-content).
- `database/migrations/*` : création/altérations des tables.
- `database/seeders/*` : données de démonstration (optionnel).

## Conventions de code
- **Colonnes** : noms explicites (`exercise_body_part`, `session_date`).
- **PK** : `*_id` (bigIncrements).
- **FK** : `{entity}_id` avec contraintes référentielles.
- **Validation** : toujours valider le body (types, min/max).
- **Scopes de sécurité** : filtrer par `user_id` côté serveur (ne jamais se fier à l’ID côté client).

## Améliorations possibles
- **Pagination** API (standard Laravel paginator + meta).
- **API Resources** (transformers) pour réponses stables et versionnables.
- **Scribe / Swagger** pour doc auto.
- **Policies** pour affiner les autorisations.
- **TTL tokens** avec middleware `EnsureTokenNotExpired`.
- **Tests** : Feature tests des endpoints + validations.

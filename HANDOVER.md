# KeepProgress — Guide de reprise (handover)

Objectif : permettre à un(e) développeur·se de **reprendre, comprendre et terminer** le projet (côté back & intégration mobile).

## 1) Mise en route rapide
1. Cloner le repo, copier `.env` et configurer la BDD MySQL (voir README).
2. `composer install` puis `php artisan key:generate`.
3. `php artisan migrate` (inclut Sanctum).
4. (Optionnel) `php artisan db:seed` pour exemples.
5. Démarrer : `php artisan serve`.

### Comptes admin
Créer un admin via Tinker :
```php
use App\Models\User; use Illuminate\Support\Facades\Hash;
User::create([ 'user_name'=>'Admin','user_email'=>'admin@test.local','user_password'=>Hash::make('Admin123!'),'isAdmin'=>true ]);
```
Accès Filament : `/admin` (seuls `isAdmin=true`).

## 2) Où sont les choses ?
- **API** : `routes/api.php` (login, me, exercises, training-sessions, session-content).
- **Admin (Filament)** : `app/Filament/Resources/*`.
- **Modèles** : `app/Models/*` (User, Exercise, TrainingSession, SessionContent, Gym).
- **Migrations** : `database/migrations/*`.
- **Seeders** : `database/seeders/*`.

## 3) Points d’attention
- **Mapping User (crucial)** : dans `User.php` utiliser
  ```php
  public function getAuthPasswordName(): string { return 'user_password'; }
  public function getAuthPassword(): string { return $this->user_password; }
  ```
  sinon Laravel tentera d’écrire dans `password` au rehash.
- **Auth Sanctum** :
  - Login crée un token **Bearer** à transmettre sur chaque requête.
  - Toutes les routes sensibles sont sous `auth:sanctum`.
- **Sécurité** :
  - Toujours filtrer par `user_id` côté serveur (ex: sessions d’un autre user interdites).
  - HTTPS en prod, rate limit `/api/login`.
  - Stockage sécurisé des tokens côté mobile.

## 4) Étendre l’API (exemples)
### A) Pagination des exercices
```php
Route::get('/exercises', function () {
    return \App\Models\Exercise::query()
        ->select('exercise_id','exercise_name','exercise_body_part','exercise_description','updated_at')
        ->orderBy('exercise_name')
        ->paginate(20);
});
```
Réponse inclut `data`, `links`, `meta` (convention Laravel).

### B) Filtrer par body part
```php
Route::get('/exercises', function (\Illuminate\Http\Request $request) {
    return \App\Models\Exercise::query()
        ->when($request->body_part, fn($q,$bp)=>$q->where('exercise_body_part',$bp))
        ->orderBy('exercise_name')
        ->get(['exercise_id','exercise_name','exercise_body_part','exercise_description','updated_at']);
});
```

### C) API Resources (transformers)
Créer `app/Http/Resources/ExerciseResource.php` et retourner `ExerciseResource::collection($query->get())` pour pérenniser le contrat JSON.

### D) FormRequests
Créer des classes `FormRequest` pour isoler la validation (ex: `StoreTrainingSessionRequest`).

## 5) Déploiement (prod)
- Server PHP-FPM + Nginx, HTTPS (Let’s Encrypt).
- `.env` prod sécurisé (APP_KEY, DB, LOG_LEVEL=info).
- `php artisan migrate --force` en CI/CD.
- Sauvegardes BDD + rotation.
- Logs & monitoring (fail2ban/WAF si nécessaire).

## 6) Intégration mobile (Android)
- **Login** → POST `/api/login` → récupérer `token`.
- Enregistrer le token **de façon sécurisée**.
- Ajouter le header `Authorization: Bearer <token>` sur chaque appel.
- Gérer les statuts :  
  - `401` → renvoyer vers login,  
  - `422` → afficher erreurs de champs,  
  - `429` → rate limit (attendre).
- Endpoints prêts :
  - `GET /api/exercises`
  - `GET /api/training-sessions`
  - `POST /api/training-sessions`
  - `GET /api/session-content?training_session_id=<id>`
  - `POST /api/session-content`

## 7) TODO / Roadmap pour terminer
- [ ] API Resources + pagination standardisée
- [ ] Filtres API (dates, body part, recherche texte)
- [ ] Tests Feature (auth + endpoints clés)
- [ ] Doc auto (Scribe ou Swagger)
- [ ] TTL tokens (champ `expires_at` + middleware)
- [ ] Rôles/policies si besoin d’admin non technique
- [ ] Upload d’images pour les exercices (optionnel)
- [ ] Exports CSV depuis Filament (optionnel)

## 8) Dépannage rapide
- **404 sur `/api/*`** → vérifier `bootstrap/app.php` (`->withRouting(api: routes/api.php)`).
- **Update `password` au login** → vérifier `getAuthPasswordName()`/`getAuthPassword()`.
- **FK sessions** → vérifier que les `users` existent avant seed de sessions.
- **Hash invalide** → générer via `Hash::make()` (doit commencer par `$2y$`).

Bon courage et bonne reprise ! 🚀

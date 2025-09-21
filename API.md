# KeepProgress — API Reference (v1)

Base URL local: `http://127.0.0.1:8000`  
Auth: **Bearer token** (Sanctum)

---

## Authentification

### POST /api/login
Connexion utilisateur et récupération d’un token.
```json
{
  "email": "user1@test.com",
  "password": "Test31!"
}
```

**Réponse :**
```json
{
  "token": "1|<long-token>",
  "token_type": "Bearer",
  "user": {
    "id": 1,
    "name": "User 1",
    "email": "user1@test.com"
  }
}
```

---

### GET /api/me
Retourne les infos du user authentifié.

**Headers :**
```
Authorization: Bearer <token>
```

**Réponse :**
```json
{
  "id": 1,
  "name": "User 1",
  "email": "user1@test.com",
  "isAdmin": false
}
```

---

### POST /api/logout
Révoque le token courant.

### POST /api/logout-all
Révoque tous les tokens de l’utilisateur.

---

## Exercices

### GET /api/exercises
Liste tous les exercices.

**Headers :** `Authorization: Bearer <token>`

**Réponse :**
```json
[
  {
    "exercise_id": 1,
    "exercise_name": "Développé couché",
    "exercise_body_part": "chest",
    "exercise_description": "Exercice de base pour la poitrine",
    "updated_at": "2025-09-18T17:00:00.000000Z"
  },
  {
    "exercise_id": 2,
    "exercise_name": "Tractions pronation",
    "exercise_body_part": "back",
    "exercise_description": "Exercice de base pour le dos",
    "updated_at": "2025-09-18T17:00:00.000000Z"
  }
]
```

---

## Training Sessions

### GET /api/training-sessions
Liste les sessions de l’utilisateur connecté.

**Headers :**
```
Authorization: Bearer <token>
```

**Réponse :**
```json
[
  {
    "training_session_id": 5,
    "user_id": 1,
    "session_date": "2025-09-17 18:30:00",
    "duration": 60,
    "created_at": "2025-09-17T18:30:00.000000Z",
    "updated_at": "2025-09-17T18:45:00.000000Z"
  }
]
```

### POST /api/training-sessions
Crée une nouvelle session.

**Headers :**
```
Authorization: Bearer <token>
```

**Body JSON :**
```json
{
  "session_date": "2025-09-19 18:30:00",
  "duration": 60
}
```

**Réponse :**
```json
{
  "training_session_id": 7,
  "user_id": 1,
  "session_date": "2025-09-19 18:30:00",
  "duration": 60
}
```

---

## Session Content

### GET /api/session-content?training_session_id=x
Retourne les exercices effectués lors d’une session.

**Headers :**
```
Authorization: Bearer <token>
```

**Réponse :**
```json
[
  {
    "session_content_id": 12,
    "training_session_id": 7,
    "exercise_id": 2,
    "sets": 4,
    "reps": 10,
    "weight": 60,
    "created_at": "2025-09-18T19:05:00.000000Z",
    "updated_at": "2025-09-18T19:05:00.000000Z"
  }
]
```

### POST /api/session-content
Ajoute un exercice à une session.

**Headers :**
```
Authorization: Bearer <token>
```

**Body JSON :**
```json
{
  "training_session_id": 7,
  "exercise_id": 2,
  "sets": 4,
  "reps": 10,
  "weight": 60
}
```

**Réponse :**
```json
{
  "session_content_id": 14,
  "training_session_id": 7,
  "exercise_id": 2,
  "sets": 4,
  "reps": 10,
  "weight": 60
}
```

---

## Codes d’erreur
- **401 Unauthorized** : Token manquant ou invalide
- **403 Forbidden** : Ressource qui n’appartient pas à l’utilisateur
- **422 Unprocessable Entity** : Erreur de validation (format date, champs manquants…)
- **429 Too Many Requests** : Trop de tentatives (rate limit)
- **500 Server Error** : Erreur interne

---

## Notes
- Les dates sont renvoyées au format ISO (UTC ou timezone serveur)
- Les endpoints `/training-sessions` et `/session-content` sont automatiquement **scopés sur l’utilisateur connecté**
- Les tokens Sanctum doivent être stockés de façon sécurisée côté mobile

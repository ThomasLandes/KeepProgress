# KeepProgress API

This is a PHP REST API for the KeepProgress mobile application. It provides endpoints for user management and session tracking.

## Setup Instructions for XAMPP

1. **Install XAMPP** if you haven't already
2. **Copy the API folder** to your XAMPP htdocs directory:
   - Copy the entire `api` folder to `C:\xampp\htdocs\keepprogressapp\`
3. **Start XAMPP** services:
   - Start Apache
   - MySQL is not required as we're using SQLite
4. **Access the API** at: `http://localhost/keepprogressapp/api/`

## API Endpoints

### Base URL
```
http://localhost/keepprogressapp/api
```

### User Endpoints

#### Register User
- **POST** `/register`
- **Body:**
```json
{
  "nom": "John Doe",
  "age": 25,
  "email": "john@example.com",
  "password": "password123"
}
```

#### Login User
- **POST** `/login`
- **Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

#### Forgot Password
- **POST** `/forgot-password`
- **Body:**
```json
{
  "email": "john@example.com"
}
```

#### Get User by ID
- **GET** `/users/{id}`
- **Example:** `/users/1`

### Session Endpoints

#### Get User Sessions
- **GET** `/sessions/{userId}`
- **Example:** `/sessions/1`

#### Add Session
- **POST** `/sessions`
- **Body:**
```json
{
  "userId": 1,
  "titre": "Morning Workout",
  "date": "2025-07-15T08:00:00.000Z"
}
```

#### Delete Session
- **DELETE** `/sessions/{sessionId}`
- **Example:** `/sessions/1`

## Database

The API uses SQLite database which will be automatically created in the `api` directory as `keeprogress.db`.

### Tables Structure

#### Users Table
- `id` (INTEGER PRIMARY KEY)
- `nom` (TEXT)
- `age` (INTEGER)
- `email` (TEXT UNIQUE)
- `password` (TEXT - hashed)
- `created_at` (DATETIME)

#### Sessions Table
- `id` (INTEGER PRIMARY KEY)
- `user_id` (INTEGER - foreign key)
- `titre` (TEXT)
- `date` (DATETIME)
- `created_at` (DATETIME)

## Update Your Flutter App

To use this API with your Flutter app, update the `baseUrl` in `api_service.dart`:

```dart
static const String baseUrl = 'http://localhost/keepprogressapp/api';
```

Or if testing on a physical device, use your computer's IP address:
```dart
static const String baseUrl = 'http://192.168.1.XXX/keepprogressapp/api';
```

## Testing the API

You can test the API using:
- **Postman** or **Insomnia**
- **curl** commands
- Your Flutter app directly

### Example curl commands:

```bash
# Register a user
curl -X POST http://localhost/keepprogressapp/api/register \
  -H "Content-Type: application/json" \
  -d '{"nom":"Test User","age":25,"email":"test@example.com","password":"password123"}'

# Login
curl -X POST http://localhost/keepprogressapp/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Get user by ID
curl http://localhost/keepprogressapp/api/users/1

# Add session
curl -X POST http://localhost/keepprogressapp/api/sessions \
  -H "Content-Type: application/json" \
  -d '{"userId":1,"titre":"Test Session","date":"2025-07-15T10:00:00.000Z"}'
```

## Error Handling

The API returns appropriate HTTP status codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `409` - Conflict (e.g., email already exists)
- `500` - Internal Server Error

All error responses include a JSON object with an `error` field describing the issue.

## Security Notes

This is a development/testing API. For production use, consider:
- Adding authentication tokens (JWT)
- Implementing rate limiting
- Adding input validation and sanitization
- Using HTTPS
- Adding proper logging
- Implementing password reset functionality

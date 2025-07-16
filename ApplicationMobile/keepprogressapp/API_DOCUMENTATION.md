# KeepProgress API Documentation

## Base URL
```
http://your-vps-ip/keepprogress_api
```

## Authentication
All protected endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer your_jwt_token
```

## Endpoints

### Authentication

#### Register User
- **POST** `/auth/register.php`
- **Body:**
```json
{
    "nom": "John Doe",
    "age": 25,
    "email": "john@example.com",
    "password": "password123"
}
```
- **Response:**
```json
{
    "success": true,
    "message": "User registered successfully",
    "token": "your_jwt_token",
    "user": {
        "id": 1,
        "nom": "John Doe",
        "age": 25,
        "email": "john@example.com"
    }
}
```

#### Login User
- **POST** `/auth/login.php`
- **Body:**
```json
{
    "email": "john@example.com",
    "password": "password123"
}
```
- **Response:**
```json
{
    "success": true,
    "message": "Login successful",
    "token": "your_jwt_token",
    "user": {
        "id": 1,
        "nom": "John Doe",
        "age": 25,
        "email": "john@example.com"
    }
}
```

#### Logout User
- **POST** `/auth/logout.php`
- **Headers:** `Authorization: Bearer your_jwt_token`
- **Response:**
```json
{
    "success": true,
    "message": "Logout successful"
}
```

### User Profile

#### Get User Profile
- **GET** `/user/profile.php`
- **Headers:** `Authorization: Bearer your_jwt_token`
- **Response:**
```json
{
    "success": true,
    "message": "Profile retrieved successfully",
    "data": {
        "user": {
            "id": 1,
            "nom": "John Doe",
            "age": 25,
            "email": "john@example.com",
            "created_at": "2025-01-15 10:00:00"
        }
    }
}
```

#### Update User Profile
- **PUT** `/user/profile.php`
- **Headers:** `Authorization: Bearer your_jwt_token`
- **Body:**
```json
{
    "nom": "John Smith",
    "age": 26,
    "email": "john.smith@example.com"
}
```

### Progress Tracking

#### Get All Progress
- **GET** `/progress/`
- **Headers:** `Authorization: Bearer your_jwt_token`
- **Response:**
```json
{
    "success": true,
    "message": "Progress retrieved successfully",
    "data": {
        "progress": [
            {
                "id": 1,
                "title": "Weight Loss",
                "description": "Lose 10kg in 6 months",
                "target_value": 10.0,
                "current_value": 3.5,
                "unit": "kg",
                "category": "fitness",
                "start_date": "2025-01-01",
                "target_date": "2025-06-30",
                "is_completed": false,
                "created_at": "2025-01-15 10:00:00",
                "updated_at": "2025-01-15 10:00:00"
            }
        ]
    }
}
```

#### Create New Progress
- **POST** `/progress/`
- **Headers:** `Authorization: Bearer your_jwt_token`
- **Body:**
```json
{
    "title": "Weight Loss",
    "description": "Lose 10kg in 6 months",
    "target_value": 10.0,
    "current_value": 0.0,
    "unit": "kg",
    "category": "fitness",
    "start_date": "2025-01-01",
    "target_date": "2025-06-30"
}
```

#### Get Specific Progress
- **GET** `/progress/{id}`
- **Headers:** `Authorization: Bearer your_jwt_token`

#### Update Progress
- **PUT** `/progress/{id}`
- **Headers:** `Authorization: Bearer your_jwt_token`
- **Body:**
```json
{
    "current_value": 5.0,
    "is_completed": false
}
```

#### Delete Progress
- **DELETE** `/progress/{id}`
- **Headers:** `Authorization: Bearer your_jwt_token`

## Error Responses

All error responses follow this format:
```json
{
    "success": false,
    "message": "Error description",
    "data": {} // Optional additional error data
}
```

### Common HTTP Status Codes
- `200` - Success
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `405` - Method Not Allowed
- `409` - Conflict (e.g., email already exists)
- `422` - Validation Error
- `500` - Internal Server Error

## Setup Instructions

1. **Database Setup:**
   - Run the SQL script in `database.sql`
   - Update database credentials in `api/config/database.php`

2. **File Structure:**
```
keepprogress_api/
├── config/
│   └── database.php
├── helpers/
│   ├── TokenHelper.php
│   └── ResponseHelper.php
├── middleware/
│   └── AuthMiddleware.php
├── auth/
│   ├── register.php
│   ├── login.php
│   └── logout.php
├── user/
│   └── profile.php
└── progress/
    └── index.php
```

3. **Security Notes:**
   - Change the secret key in `TokenHelper.php`
   - Update database credentials
   - Configure HTTPS in production
   - Set up proper CORS policies

4. **Testing:**
   - Use Postman or similar tools to test endpoints
   - Update Flutter app base URL to your VPS IP

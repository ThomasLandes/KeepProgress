<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'config.php';
require_once 'database.php';

// Initialize database
$database = new Database();

// Get request method and URI
$method = $_SERVER['REQUEST_METHOD'];
$request = $_SERVER['REQUEST_URI'];
$path = parse_url($request, PHP_URL_PATH);
$path = str_replace('/api', '', $path);

// Get request body for POST/PUT requests
$input = json_decode(file_get_contents('php://input'), true);

// Route handling
switch ($method) {
    case 'GET':
        handleGet($path, $database);
        break;
    case 'POST':
        handlePost($path, $input, $database);
        break;
    case 'DELETE':
        handleDelete($path, $database);
        break;
    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        break;
}

function handleGet($path, $database) {
    if (preg_match('/^\/users\/(\d+)$/', $path, $matches)) {
        // Get user by ID
        $userId = $matches[1];
        $user = $database->getUserById($userId);
        if ($user) {
            echo json_encode($user);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'User not found']);
        }
    } elseif (preg_match('/^\/sessions\/(\d+)$/', $path, $matches)) {
        // Get sessions for user
        $userId = $matches[1];
        $sessions = $database->getSessionsByUserId($userId);
        echo json_encode($sessions);
    } else {
        http_response_code(404);
        echo json_encode(['error' => 'Endpoint not found']);
    }
}

function handlePost($path, $input, $database) {
    switch ($path) {
        case '/register':
            handleRegister($input, $database);
            break;
        case '/login':
            handleLogin($input, $database);
            break;
        case '/forgot-password':
            handleForgotPassword($input, $database);
            break;
        case '/sessions':
            handleAddSession($input, $database);
            break;
        default:
            http_response_code(404);
            echo json_encode(['error' => 'Endpoint not found']);
            break;
    }
}

function handleDelete($path, $database) {
    if (preg_match('/^\/sessions\/(\d+)$/', $path, $matches)) {
        $sessionId = $matches[1];
        $result = $database->deleteSession($sessionId);
        if ($result) {
            echo json_encode(['success' => true, 'message' => 'Session deleted successfully']);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Session not found']);
        }
    } else {
        http_response_code(404);
        echo json_encode(['error' => 'Endpoint not found']);
    }
}

function handleRegister($input, $database) {
    // Validate input
    if (!isset($input['nom']) || !isset($input['age']) || !isset($input['email']) || !isset($input['password'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing required fields: nom, age, email, password']);
        return;
    }

    $nom = $input['nom'];
    $age = (int)$input['age'];
    $email = $input['email'];
    $password = $input['password'];

    // Validate email format
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid email format']);
        return;
    }

    // Check if user already exists
    if ($database->getUserByEmail($email)) {
        http_response_code(409);
        echo json_encode(['error' => 'User with this email already exists']);
        return;
    }

    // Hash password
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    // Create user
    $userId = $database->createUser($nom, $age, $email, $hashedPassword);
    
    if ($userId) {
        http_response_code(201);
        echo json_encode([
            'success' => true,
            'message' => 'User created successfully',
            'userId' => $userId
        ]);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to create user']);
    }
}

function handleLogin($input, $database) {
    if (!isset($input['email']) || !isset($input['password'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing email or password']);
        return;
    }

    $email = $input['email'];
    $password = $input['password'];

    $user = $database->getUserByEmail($email);
    
    if ($user && password_verify($password, $user['password'])) {
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Login successful',
            'user' => [
                'id' => $user['id'],
                'nom' => $user['nom'],
                'age' => $user['age'],
                'email' => $user['email']
            ]
        ]);
    } else {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid credentials']);
    }
}

function handleForgotPassword($input, $database) {
    if (!isset($input['email'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing email']);
        return;
    }

    $email = $input['email'];
    $user = $database->getUserByEmail($email);

    if ($user) {
        // In a real application, you would send an email here
        // For testing purposes, we'll just return success
        echo json_encode([
            'success' => true,
            'message' => 'Password reset email sent (simulated)'
        ]);
    } else {
        http_response_code(404);
        echo json_encode(['error' => 'User not found']);
    }
}

function handleAddSession($input, $database) {
    if (!isset($input['userId']) || !isset($input['titre']) || !isset($input['date'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing required fields: userId, titre, date']);
        return;
    }

    $userId = (int)$input['userId'];
    $titre = $input['titre'];
    $date = $input['date'];

    // Validate date format
    $dateTime = DateTime::createFromFormat('Y-m-d\TH:i:s.u\Z', $date);
    if (!$dateTime) {
        $dateTime = DateTime::createFromFormat('Y-m-d\TH:i:s\Z', $date);
    }
    if (!$dateTime) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid date format']);
        return;
    }

    $sessionId = $database->createSession($userId, $titre, $dateTime->format('Y-m-d H:i:s'));
    
    if ($sessionId) {
        http_response_code(201);
        echo json_encode([
            'success' => true,
            'message' => 'Session created successfully',
            'sessionId' => $sessionId
        ]);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to create session']);
    }
}
?>

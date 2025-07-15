<?php
// Test script to verify API functionality
require_once 'config.php';
require_once 'database.php';

header('Content-Type: application/json');

// Initialize database
$database = new Database();

$tests = [];

// Test 1: Create a test user
$testUser = [
    'nom' => 'Test User',
    'age' => 25,
    'email' => 'test@example.com',
    'password' => password_hash('password123', PASSWORD_DEFAULT)
];

$userId = $database->createUser(
    $testUser['nom'],
    $testUser['age'],
    $testUser['email'],
    $testUser['password']
);

$tests['create_user'] = $userId ? 'PASS' : 'FAIL';

if ($userId) {
    // Test 2: Get user by ID
    $user = $database->getUserById($userId);
    $tests['get_user_by_id'] = $user ? 'PASS' : 'FAIL';

    // Test 3: Get user by email
    $userByEmail = $database->getUserByEmail($testUser['email']);
    $tests['get_user_by_email'] = $userByEmail ? 'PASS' : 'FAIL';

    // Test 4: Create a test session
    $sessionId = $database->createSession($userId, 'Test Session', date('Y-m-d H:i:s'));
    $tests['create_session'] = $sessionId ? 'PASS' : 'FAIL';

    if ($sessionId) {
        // Test 5: Get sessions by user ID
        $sessions = $database->getSessionsByUserId($userId);
        $tests['get_sessions_by_user'] = (count($sessions) > 0) ? 'PASS' : 'FAIL';

        // Test 6: Delete session
        $deleteResult = $database->deleteSession($sessionId);
        $tests['delete_session'] = $deleteResult ? 'PASS' : 'FAIL';
    }

    // Test 7: Delete user
    $deleteUser = $database->deleteUser($userId);
    $tests['delete_user'] = $deleteUser ? 'PASS' : 'FAIL';
}

// Output test results
echo json_encode([
    'message' => 'API Test Results',
    'tests' => $tests,
    'overall' => in_array('FAIL', $tests) ? 'SOME TESTS FAILED' : 'ALL TESTS PASSED'
], JSON_PRETTY_PRINT);
?>

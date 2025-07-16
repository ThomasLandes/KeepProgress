<?php
/**
 * User Profile Endpoint
 * GET /user/profile.php - Get current user profile only
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once '../middleware/AuthMiddleware.php';

try {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // Get user profile
        $user = AuthMiddleware::getCurrentUser();
        
        ResponseHelper::success('Profile retrieved successfully', [
            'user' => $user
        ]);
        
    } else {
        ResponseHelper::error('Method not allowed', 405);
    }
    
} catch (Exception $e) {
    error_log("Erreur profile endpoint: " . $e->getMessage());
    ResponseHelper::error('Erreur interne du serveur', 500);
}
?>

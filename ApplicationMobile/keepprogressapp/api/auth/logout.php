<?php
/**
 * Endpoint de Déconnexion Utilisateur
 * POST /auth/logout.php
 */

// En-têtes pour CORS et type de contenu
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Gérer les requêtes preflight OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Autoriser seulement les requêtes POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Méthode non autorisée']);
    exit;
}

require_once '../middleware/AuthMiddleware.php';

try {
    // Récupérer le token actuel depuis les en-têtes
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    
    if (!empty($authHeader) && strpos($authHeader, 'Bearer ') === 0) {
        $token = substr($authHeader, 7);
        
        // Révoquer le token
        TokenHelper::revokeToken($token);
    }
    
    ResponseHelper::success('Déconnexion réussie');
    
} catch (Exception $e) {
    error_log("Erreur de déconnexion: " . $e->getMessage());
    ResponseHelper::error('Erreur interne du serveur', 500);
}
?>

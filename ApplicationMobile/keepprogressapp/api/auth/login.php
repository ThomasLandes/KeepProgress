<?php
/**
 * Endpoint de Connexion Utilisateur
 * POST /auth/login.php
 */

// En-têtes pour CORS et type de contenu
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

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

require_once '../config/database.php';
require_once '../helpers/TokenHelper.php';
require_once '../helpers/ResponseHelper.php';

try {
    // Récupérer les données JSON envoyées
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        ResponseHelper::error('Données JSON invalides');
    }
    
    // Valider les champs requis
    if (!isset($input['email']) || !isset($input['password'])) {
        ResponseHelper::validationError('Email et mot de passe sont requis');
    }
    
    $email = trim(strtolower($input['email']));
    $password = $input['password'];
    
    // Validation du format email
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        ResponseHelper::validationError('Format d\'email invalide');
    }
    
    if (empty($password)) {
        ResponseHelper::validationError('Le mot de passe est requis');
    }
    
    $db = Database::getConnection();
    
    // Chercher l'utilisateur par email
    $stmt = $db->prepare("SELECT id, nom, age, email, password_hash FROM users WHERE email = ? AND is_active = TRUE");
    $stmt->execute([$email]);
    $user = $stmt->fetch();
    
    if (!$user) {
        ResponseHelper::error('Email ou mot de passe invalide', 401);
    }
    
    // Vérifier le mot de passe
    if (!password_verify($password, $user['password_hash'])) {
        ResponseHelper::error('Email ou mot de passe invalide', 401);
    }
    
    // Générer le token d'authentification
    $token = TokenHelper::generateToken($user['id']);
    
    // Stocker le token en base de données
    TokenHelper::storeToken($user['id'], $token);
    
    // Préparer les données utilisateur (sans le mot de passe)
    $user_data = [
        'id' => $user['id'],
        'nom' => $user['nom'],
        'age' => $user['age'],
        'email' => $user['email']
    ];
    
    ResponseHelper::authSuccess('Connexion réussie', $token, $user_data);
    
} catch (Exception $e) {
    error_log("Erreur de connexion: " . $e->getMessage());
    ResponseHelper::error('Erreur interne du serveur', 500);
}
?>

<?php
/**
 * Endpoint d'Inscription Utilisateur
 * POST /auth/register.php
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
    $required_fields = ['nom', 'age', 'email', 'password'];
    $missing_fields = [];
    
    foreach ($required_fields as $field) {
        if (!isset($input[$field]) || empty(trim($input[$field]))) {
            $missing_fields[] = $field;
        }
    }
    
    if (!empty($missing_fields)) {
        ResponseHelper::validationError('Champs requis manquants', $missing_fields);
    }
    
    // Nettoyer et préparer les données
    $nom = trim($input['nom']);
    $age = (int) $input['age'];
    $email = trim(strtolower($input['email']));
    $password = $input['password'];
    
    // Validation du format email
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        ResponseHelper::validationError('Format d\'email invalide');
    }
    
    // Validation de l'âge
    if ($age < 1 || $age > 150) {
        ResponseHelper::validationError('L\'âge doit être entre 1 et 150 ans');
    }
    
    // Validation de la force du mot de passe
    if (strlen($password) < 6) {
        ResponseHelper::validationError('Le mot de passe doit contenir au moins 6 caractères');
    }
    
    // Validation de la longueur du nom
    if (strlen($nom) < 2 || strlen($nom) > 100) {
        ResponseHelper::validationError('Le nom doit contenir entre 2 et 100 caractères');
    }
    
    $db = Database::getConnection();
    
    // Vérifier si l'email existe déjà
    $stmt = $db->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    
    if ($stmt->fetch()) {
        ResponseHelper::error('Email déjà enregistré', 409);
    }
    
    // Hacher le mot de passe de manière sécurisée
    $password_hash = password_hash($password, PASSWORD_DEFAULT);
    
    // Insérer le nouvel utilisateur
    $stmt = $db->prepare("INSERT INTO users (nom, age, email, password_hash) VALUES (?, ?, ?, ?)");
    $result = $stmt->execute([$nom, $age, $email, $password_hash]);
    
    if (!$result) {
        ResponseHelper::error('Échec de la création de l\'utilisateur', 500);
    }
    
    $user_id = $db->lastInsertId();
    
    // Générer le token d'authentification
    $token = TokenHelper::generateToken($user_id);
    
    // Stocker le token en base de données
    TokenHelper::storeToken($user_id, $token);
    
    // Préparer les données utilisateur (sans le mot de passe)
    $user_data = [
        'id' => $user_id,
        'nom' => $nom,
        'age' => $age,
        'email' => $email
    ];
    
    ResponseHelper::authSuccess('Utilisateur enregistré avec succès', $token, $user_data);
    
} catch (Exception $e) {
    error_log("Erreur d'inscription: " . $e->getMessage());
    ResponseHelper::error('Erreur interne du serveur', 500);
}
?>

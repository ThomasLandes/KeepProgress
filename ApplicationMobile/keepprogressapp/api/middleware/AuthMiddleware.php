<?php
/**
 * Middleware d'Authentification
 * Valide les requêtes qui nécessitent une authentification
 */

require_once '../config/database.php';
require_once '../helpers/TokenHelper.php';
require_once '../helpers/ResponseHelper.php';

class AuthMiddleware {
    
    /**
     * Authentifier l'utilisateur à partir de l'en-tête Authorization
     */
    public static function authenticate() {
        // Récupérer les en-têtes HTTP
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
        
        // Vérifier la présence de l'en-tête d'autorisation
        if (empty($authHeader)) {
            ResponseHelper::unauthorized('En-tête d\'autorisation manquant');
        }
        
        // Vérifier le format Bearer Token
        if (strpos($authHeader, 'Bearer ') !== 0) {
            ResponseHelper::unauthorized('Format d\'en-tête d\'autorisation invalide');
        }
        
        // Extraire le token (enlever "Bearer ")
        $token = substr($authHeader, 7);
        
        if (empty($token)) {
            ResponseHelper::unauthorized('Token manquant');
        }
        
        // Vérifier si le token est révoqué
        if (TokenHelper::isTokenRevoked($token)) {
            ResponseHelper::unauthorized('Le token a été révoqué');
        }
        
        // Valider le token
        $payload = TokenHelper::validateToken($token);
        if (!$payload) {
            ResponseHelper::unauthorized('Token invalide ou expiré');
        }
        
        return $payload['user_id'];
    }
    
    /**
     * Obtenir l'utilisateur actuellement authentifié
     */
    public static function getCurrentUser() {
        // Authentifier et récupérer l'ID utilisateur
        $user_id = self::authenticate();
        
        try {
            $db = Database::getConnection();
            // Récupérer les données utilisateur (sans le mot de passe)
            $stmt = $db->prepare("SELECT id, nom, age, email, created_at FROM users WHERE id = ? AND is_active = TRUE");
            $stmt->execute([$user_id]);
            $user = $stmt->fetch();
            
            if (!$user) {
                ResponseHelper::unauthorized('Utilisateur non trouvé ou inactif');
            }
            
            return $user;
        } catch (Exception $e) {
            error_log("Échec de récupération de l'utilisateur actuel: " . $e->getMessage());
            ResponseHelper::error('Erreur interne du serveur', 500);
        }
    }
}
?>

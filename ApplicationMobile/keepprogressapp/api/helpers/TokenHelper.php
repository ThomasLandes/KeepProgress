<?php
/**
 * Gestionnaire de Tokens JWT
 * Implémentation simple de type JWT pour l'authentification
 */

class TokenHelper {
    // Clé secrète pour signer les tokens (CHANGER EN PRODUCTION!)
    private static $secret_key = 'your_secret_key_change_this_in_production';
    
    /**
     * Générer un token sécurisé pour l'authentification utilisateur
     */
    public static function generateToken($user_id) {
        // Données à inclure dans le token
        $payload = [
            'user_id' => $user_id,
            'issued_at' => time(),
            'expires_at' => time() + (24 * 60 * 60) // Expire dans 24 heures
        ];
        
        // Création d'un token simple (en production, utiliser une vraie librairie JWT)
        $token = base64_encode(json_encode($payload)) . '.' . hash_hmac('sha256', json_encode($payload), self::$secret_key);
        
        return $token;
    }
    
    /**
     * Valider et décoder un token
     */
    public static function validateToken($token) {
        try {
            // Séparer le payload de la signature
            $parts = explode('.', $token);
            if (count($parts) !== 2) {
                return false;
            }
            
            // Décoder le payload et récupérer la signature
            $payload = json_decode(base64_decode($parts[0]), true);
            $signature = $parts[1];
            
            // Vérifier la signature
            $expected_signature = hash_hmac('sha256', json_encode($payload), self::$secret_key);
            if (!hash_equals($expected_signature, $signature)) {
                return false;
            }
            
            // Vérifier l'expiration
            if ($payload['expires_at'] < time()) {
                return false;
            }
            
            return $payload;
        } catch (Exception $e) {
            return false;
        }
    }
    
    /**
     * Extraire l'ID utilisateur du token
     */
    public static function getUserIdFromToken($token) {
        $payload = self::validateToken($token);
        return $payload ? $payload['user_id'] : false;
    }
    
    /**
     * Stocker le token en base de données
     */
    public static function storeToken($user_id, $token) {
        try {
            $db = Database::getConnection();
            
            // Supprimer les anciens tokens de cet utilisateur
            $stmt = $db->prepare("DELETE FROM auth_tokens WHERE user_id = ? OR expires_at < NOW()");
            $stmt->execute([$user_id]);
            
            // Stocker le nouveau token
            $payload = self::validateToken($token);
            $expires_at = date('Y-m-d H:i:s', $payload['expires_at']);
            
            $stmt = $db->prepare("INSERT INTO auth_tokens (user_id, token, expires_at) VALUES (?, ?, ?)");
            return $stmt->execute([$user_id, $token, $expires_at]);
        } catch (Exception $e) {
            error_log("Échec du stockage du token: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Révoquer un token (déconnexion)
     */
    public static function revokeToken($token) {
        try {
            $db = Database::getConnection();
            $stmt = $db->prepare("UPDATE auth_tokens SET is_revoked = TRUE WHERE token = ?");
            return $stmt->execute([$token]);
        } catch (Exception $e) {
            error_log("Échec de la révocation du token: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Vérifier si un token est révoqué
     */
    public static function isTokenRevoked($token) {
        try {
            $db = Database::getConnection();
            $stmt = $db->prepare("SELECT is_revoked FROM auth_tokens WHERE token = ?");
            $stmt->execute([$token]);
            $result = $stmt->fetch();
            
            return $result ? (bool)$result['is_revoked'] : true;
        } catch (Exception $e) {
            return true;
        }
    }
}
?>

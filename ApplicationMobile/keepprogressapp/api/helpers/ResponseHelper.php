<?php
/**
 * Gestionnaire de Réponses API
 * Réponses API standardisées pour toutes les endpoints
 */

class ResponseHelper {
    
    /**
     * Envoyer une réponse de succès
     */
    public static function success($message = 'Succès', $data = null) {
        http_response_code(200);
        $response = [
            'success' => true,
            'message' => $message
        ];
        
        if ($data !== null) {
            $response['data'] = $data;
        }
        
        self::sendJson($response);
    }
    
    /**
     * Envoyer une réponse d'erreur
     */
    public static function error($message = 'Erreur', $code = 400, $data = null) {
        http_response_code($code);
        $response = [
            'success' => false,
            'message' => $message
        ];
        
        if ($data !== null) {
            $response['data'] = $data;
        }
        
        self::sendJson($response);
    }
    
    /**
     * Envoyer une réponse d'authentification réussie avec token
     */
    public static function authSuccess($message, $token, $user = null) {
        http_response_code(200);
        $response = [
            'success' => true,
            'message' => $message,
            'token' => $token
        ];
        
        if ($user !== null) {
            $response['user'] = $user;
        }
        
        self::sendJson($response);
    }
    
    /**
     * Envoyer une réponse non autorisé (401)
     */
    public static function unauthorized($message = 'Non autorisé') {
        self::error($message, 401);
    }
    
    /**
     * Envoyer une réponse interdit (403)
     */
    public static function forbidden($message = 'Interdit') {
        self::error($message, 403);
    }
    
    /**
     * Envoyer une réponse non trouvé (404)
     */
    public static function notFound($message = 'Non trouvé') {
        self::error($message, 404);
    }
    
    /**
     * Envoyer une réponse méthode non autorisée (405)
     */
    public static function methodNotAllowed($message = 'Méthode non autorisée') {
        self::error($message, 405);
    }
    
    /**
     * Envoyer une réponse d'erreur de validation (422)
     */
    public static function validationError($message = 'Erreur de validation', $errors = []) {
        self::error($message, 422, ['validation_errors' => $errors]);
    }
    
    /**
     * Envoyer la réponse JSON et terminer l'exécution
     */
    private static function sendJson($data) {
        // En-têtes pour JSON et CORS
        header('Content-Type: application/json');
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization');
        
        echo json_encode($data, JSON_UNESCAPED_UNICODE);
        exit;
    }
}
?>

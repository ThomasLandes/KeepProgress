<?php
/**
 * Configuration de la Base de Données
 * Mise à jour des identifiants selon votre configuration VPS
 */

class Database {
    // Paramètres de connexion à la base de données
    private static $host = 'localhost';
    private static $dbname = 'keepprogress_db';
    private static $username = 'keepuser';
    private static $password = 'Keep31!'; 
    private static $pdo = null;

    /**
     * Obtenir la connexion à la base de données (Singleton pattern)
     */
    public static function getConnection() {
        if (self::$pdo === null) {
            try {
                // Configuration du DSN (Data Source Name)
                $dsn = "mysql:host=" . self::$host . ";dbname=" . self::$dbname . ";charset=utf8mb4";
                
                // Options PDO pour la sécurité et la performance
                $options = [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4"
                ];

                // Création de la connexion PDO
                self::$pdo = new PDO($dsn, self::$username, self::$password, $options);
            } catch (PDOException $e) {
                // Journalisation de l'erreur de connexion
                error_log("Échec de la connexion à la base de données: " . $e->getMessage());
                throw new Exception("Échec de la connexion à la base de données");
            }
        }
        return self::$pdo;
    }

    /**
     * Fermer la connexion à la base de données
     */
    public static function closeConnection() {
        self::$pdo = null;
    }
}
?>

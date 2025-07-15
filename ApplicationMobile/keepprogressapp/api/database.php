<?php
class Database {
    private $pdo;

    public function __construct() {
        $this->connect();
        $this->createTables();
    }

    private function connect() {
        try {
            $this->pdo = new PDO('sqlite:' . DB_FILE);
            $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            die('Database connection failed: ' . $e->getMessage());
        }
    }

    private function createTables() {
        // Create users table
        $usersTable = "
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nom TEXT NOT NULL,
                age INTEGER NOT NULL,
                email TEXT UNIQUE NOT NULL,
                password TEXT NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ";

        // Create sessions table
        $sessionsTable = "
            CREATE TABLE IF NOT EXISTS sessions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                titre TEXT NOT NULL,
                date DATETIME NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
            )
        ";

        try {
            $this->pdo->exec($usersTable);
            $this->pdo->exec($sessionsTable);
        } catch (PDOException $e) {
            die('Error creating tables: ' . $e->getMessage());
        }
    }

    // User methods
    public function createUser($nom, $age, $email, $password) {
        try {
            $stmt = $this->pdo->prepare("
                INSERT INTO users (nom, age, email, password) 
                VALUES (?, ?, ?, ?)
            ");
            $stmt->execute([$nom, $age, $email, $password]);
            return $this->pdo->lastInsertId();
        } catch (PDOException $e) {
            error_log('Error creating user: ' . $e->getMessage());
            return false;
        }
    }

    public function getUserById($id) {
        try {
            $stmt = $this->pdo->prepare("
                SELECT id, nom, age, email, created_at 
                FROM users 
                WHERE id = ?
            ");
            $stmt->execute([$id]);
            return $stmt->fetch();
        } catch (PDOException $e) {
            error_log('Error getting user by ID: ' . $e->getMessage());
            return false;
        }
    }

    public function getUserByEmail($email) {
        try {
            $stmt = $this->pdo->prepare("
                SELECT id, nom, age, email, password, created_at 
                FROM users 
                WHERE email = ?
            ");
            $stmt->execute([$email]);
            return $stmt->fetch();
        } catch (PDOException $e) {
            error_log('Error getting user by email: ' . $e->getMessage());
            return false;
        }
    }

    public function getAllUsers() {
        try {
            $stmt = $this->pdo->query("
                SELECT id, nom, age, email, created_at 
                FROM users 
                ORDER BY created_at DESC
            ");
            return $stmt->fetchAll();
        } catch (PDOException $e) {
            error_log('Error getting all users: ' . $e->getMessage());
            return [];
        }
    }

    // Session methods
    public function createSession($userId, $titre, $date) {
        try {
            $stmt = $this->pdo->prepare("
                INSERT INTO sessions (user_id, titre, date) 
                VALUES (?, ?, ?)
            ");
            $stmt->execute([$userId, $titre, $date]);
            return $this->pdo->lastInsertId();
        } catch (PDOException $e) {
            error_log('Error creating session: ' . $e->getMessage());
            return false;
        }
    }

    public function getSessionsByUserId($userId) {
        try {
            $stmt = $this->pdo->prepare("
                SELECT id, titre, date, created_at 
                FROM sessions 
                WHERE user_id = ? 
                ORDER BY date DESC
            ");
            $stmt->execute([$userId]);
            $sessions = $stmt->fetchAll();
            
            // Format sessions for API response
            $formattedSessions = [];
            foreach ($sessions as $session) {
                $formattedSessions[] = [
                    'id' => (string)$session['id'],
                    'titre' => $session['titre'],
                    'date' => date('c', strtotime($session['date'])) // ISO 8601 format
                ];
            }
            
            return $formattedSessions;
        } catch (PDOException $e) {
            error_log('Error getting sessions by user ID: ' . $e->getMessage());
            return [];
        }
    }

    public function getSessionById($id) {
        try {
            $stmt = $this->pdo->prepare("
                SELECT * FROM sessions WHERE id = ?
            ");
            $stmt->execute([$id]);
            return $stmt->fetch();
        } catch (PDOException $e) {
            error_log('Error getting session by ID: ' . $e->getMessage());
            return false;
        }
    }

    public function deleteSession($id) {
        try {
            $stmt = $this->pdo->prepare("DELETE FROM sessions WHERE id = ?");
            $stmt->execute([$id]);
            return $stmt->rowCount() > 0;
        } catch (PDOException $e) {
            error_log('Error deleting session: ' . $e->getMessage());
            return false;
        }
    }

    public function updateSession($id, $titre, $date) {
        try {
            $stmt = $this->pdo->prepare("
                UPDATE sessions 
                SET titre = ?, date = ? 
                WHERE id = ?
            ");
            $stmt->execute([$titre, $date, $id]);
            return $stmt->rowCount() > 0;
        } catch (PDOException $e) {
            error_log('Error updating session: ' . $e->getMessage());
            return false;
        }
    }

    // Utility methods
    public function deleteUser($id) {
        try {
            // Delete user (sessions will be deleted automatically due to foreign key constraint)
            $stmt = $this->pdo->prepare("DELETE FROM users WHERE id = ?");
            $stmt->execute([$id]);
            return $stmt->rowCount() > 0;
        } catch (PDOException $e) {
            error_log('Error deleting user: ' . $e->getMessage());
            return false;
        }
    }

    public function getUserStats($userId) {
        try {
            $stmt = $this->pdo->prepare("
                SELECT 
                    COUNT(*) as total_sessions,
                    MIN(date) as first_session,
                    MAX(date) as last_session
                FROM sessions 
                WHERE user_id = ?
            ");
            $stmt->execute([$userId]);
            return $stmt->fetch();
        } catch (PDOException $e) {
            error_log('Error getting user stats: ' . $e->getMessage());
            return false;
        }
    }
}
?>

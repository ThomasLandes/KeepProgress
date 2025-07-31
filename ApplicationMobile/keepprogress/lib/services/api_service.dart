import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:keepprogress/models/user_model.dart';
import 'package:keepprogress/services/session_manager.dart';

/// Service API
/// Gère toutes les communications avec l'API backend
class ApiService {
  // Cache en mémoire des utilisateurs
  static List<Map<String, dynamic>> _users = [];
  static bool _isLoaded = false;

  // Nom du fichier de stockage
  static const String _usersFileName = 'users_data.json';

  /// Obtenir le chemin du fichier de stockage
  static Future<File> _getUsersFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_usersFileName');
  }

  /// Charger les utilisateurs depuis le fichier
  static Future<void> _loadUsers() async {
    if (_isLoaded) return;

    try {
      final file = await _getUsersFile();

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        _users = jsonList.cast<Map<String, dynamic>>();
        debugPrint("API: ${_users.length} utilisateurs chargés depuis le fichier");
      } else {
        // Si le fichier n'existe pas, créer les utilisateurs par défaut
        _users = [
          {'id': 1, 'nom': 'John Doe', 'age': 25, 'email': 'john@test.com', 'password': 'password123'},
          {'id': 2, 'nom': 'Jane Smith', 'age': 30, 'email': 'jane@test.com', 'password': 'password456'},
        ];
        await _saveUsers();
        debugPrint("API: Fichier créé avec les utilisateurs par défaut");
      }
    } catch (e) {
      debugPrint("API: Erreur lors du chargement: $e");
      // En cas d'erreur, utiliser les données par défaut
      _users = [
        {'id': 1, 'nom': 'John Doe', 'age': 25, 'email': 'john@test.com', 'password': 'password123'},
        {'id': 2, 'nom': 'Jane Smith', 'age': 30, 'email': 'jane@test.com', 'password': 'password456'},
      ];
    }

    _isLoaded = true;
  }

  /// Sauvegarder les utilisateurs dans le fichier
  static Future<void> _saveUsers() async {
    try {
      final file = await _getUsersFile();
      await file.writeAsString(jsonEncode(_users));
      debugPrint("API: ${_users.length} utilisateurs sauvegardés dans le fichier");
    } catch (e) {
      debugPrint("API: Erreur lors de la sauvegarde: $e");
    }
  }

  // Délai réseau pour améliorer l'expérience utilisateur
  static Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 800));
  }

  // Génération d'un token JWT
  static String _generateMockToken(String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final payload = base64Encode(utf8.encode('{"email":"$email","exp":$timestamp}'));
    return 'mock.token.$payload';
  }

  //////////////////
  // INSCRIPTION  //
  //////////////////
  /// Inscrire un nouvel utilisateur
  /// Retourne: (succès, message, token)
  static Future<(bool, String, String?)> register(User user, String password) async {
    debugPrint("API: Tentative d'inscription pour ${user.email}");

    // Charger les utilisateurs depuis le fichier
    await _loadUsers();

    await _simulateNetworkDelay();

    try {
      // Vérifier si l'email existe déjà
      final existingUser = _users.firstWhere((u) => u['email'] == user.email, orElse: () => {});

      if (existingUser.isNotEmpty) {
        return (false, 'Un compte avec cet email existe déjà', null);
      }

      // Validation des données
      if (user.nom.trim().length < 2) {
        return (false, 'Le nom doit contenir au moins 2 caractères', null);
      }

      if (user.age < 13 || user.age > 120) {
        return (false, 'L\'âge doit être entre 13 et 120 ans', null);
      }

      if (!user.email.contains('@') || !user.email.contains('.')) {
        return (false, 'Format d\'email invalide', null);
      }

      if (password.length < 6) {
        return (false, 'Le mot de passe doit contenir au moins 6 caractères', null);
      }

      // Ajouter le nouvel utilisateur
      final newUser = {
        'id': _users.length + 1,
        'nom': user.nom.trim(),
        'age': user.age,
        'email': user.email.toLowerCase().trim(),
        'password': password,
      };

      _users.add(newUser);

      // Sauvegarder dans le fichier
      await _saveUsers();

      // Générer un token
      final token = _generateMockToken(user.email);

      debugPrint("API: Inscription réussie pour ${user.email}");
      return (true, 'Inscription réussie ! Bienvenue ${user.nom}', token);
    } catch (e) {
      return (false, 'Erreur lors de l\'envoi de la requête: $e', null);
    }
  }

  ///////////////
  // CONNEXION //
  ///////////////
  /// Connecter un utilisateur existant
  /// Retourne: (succès, message, token)
  static Future<(bool, String, String?)> login(String email, String password) async {
    debugPrint("API: Tentative de connexion pour $email");

    // Charger les utilisateurs depuis le fichier
    await _loadUsers();

    await _simulateNetworkDelay();

    try {
      // Rechercher l'utilisateur
      final user = _users.firstWhere(
        (u) => u['email'].toLowerCase() == email.toLowerCase().trim(),
        orElse: () => {},
      );

      if (user.isEmpty) {
        return (false, 'Aucun compte trouvé avec cet email', null);
      }

      // Vérifier le mot de passe
      if (user['password'] != password) {
        return (false, 'Mot de passe incorrect', null);
      }

      // Générer un token
      final token = _generateMockToken(email);

      debugPrint("API: Connexion réussie pour $email");
      return (true, 'Connexion réussie ! Bienvenue ${user['nom']}', token);
    } catch (e) {
      return (false, 'Erreur lors de la requête : $e', null);
    }
  }

  ///////////
  //LOGOUT///
  ///////////
  static Future<bool> logout() async {
    debugPrint("API: Déconnexion");

    try {
      // Effacer le token stocké
      await SessionManager.clearToken();
      return true;
    } catch (e) {
      debugPrint("Erreur logout: $e");
      return false;
    }
  }

  ////////////////////////
  ///AUTHENTICATED GET///
  ////////////////////////
  static Future<http.Response?> authenticatedGet(String endpoint) async {
    debugPrint("API: GET authentifié pour $endpoint");

    // Charger les utilisateurs depuis le fichier
    await _loadUsers();

    await _simulateNetworkDelay();

    try {
      // Simuler une réponse HTTP
      if (endpoint == '/user/profile.php') {
        final token = await SessionManager.getToken();
        if (token == null || !token.startsWith('mock.token.')) {
          return http.Response('{"success": false, "message": "Token invalide"}', 401);
        }

        // Décoder le token pour récupérer l'email
        final parts = token.split('.');
        if (parts.length != 3) {
          return http.Response('{"success": false, "message": "Format de token invalide"}', 401);
        }

        final payload = utf8.decode(base64Decode(parts[2]));
        final tokenData = jsonDecode(payload);
        final email = tokenData['email'];

        // Rechercher l'utilisateur correspondant
        final userData = _users.firstWhere(
          (u) => u['email'].toLowerCase() == email.toLowerCase(),
          orElse: () => {},
        );

        if (userData.isEmpty) {
          return http.Response('{"success": false, "message": "Utilisateur non trouvé"}', 404);
        }

        final responseData = {
          'success': true,
          'data': {
            'user': {'nom': userData['nom'], 'age': userData['age'], 'email': userData['email']},
          },
        };

        return http.Response(jsonEncode(responseData), 200, headers: {'content-type': 'application/json'});
      }

      return http.Response('{"success": false, "message": "Endpoint non trouvé"}', 404);
    } catch (e) {
      debugPrint("Erreur authenticated GET: $e");
      return null;
    }
  }

  ////////////////////////
  ///GET USER PROFILE/////
  ////////////////////////
  static Future<User?> getUserProfile() async {
    debugPrint("API: Récupération du profil utilisateur");

    final response = await authenticatedGet('/user/profile.php');

    if (response?.statusCode == 200) {
      try {
        final data = jsonDecode(response!.body);

        if (data['success'] == true && data['data'] != null && data['data']['user'] != null) {
          final userData = data['data']['user'];
          final user = User(
            nom: userData['nom'] ?? '',
            age: userData['age'] ?? 0,
            email: userData['email'] ?? '',
          );

          debugPrint("API: Profil récupéré pour ${user.email}");
          return user;
        }
      } catch (e) {
        debugPrint("Erreur parsing user profile: $e");
      }
    }

    return null;
  }

  /////////////////////
  ///HELPER METHODS///
  /////////////////////

  // Note: Les méthodes suivantes sont spécifiques à cette implémentation
  // et ne seraient pas disponibles dans l'API de production

  /// Lister tous les utilisateurs (pour développement uniquement)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    await _loadUsers();
    return _users.map((user) {
      final userCopy = Map<String, dynamic>.from(user);
      userCopy.remove('password'); // Ne pas exposer les mots de passe
      return userCopy;
    }).toList();
  }

  /// Réinitialiser la base de données (pour développement uniquement)
  static Future<void> resetDatabase() async {
    _users.clear();
    _users.addAll([
      {'id': 1, 'nom': 'John Doe', 'age': 25, 'email': 'john@test.com', 'password': 'password123'},
      {'id': 2, 'nom': 'Jane Smith', 'age': 30, 'email': 'jane@test.com', 'password': 'password456'},
    ]);
    await _saveUsers();
    debugPrint("API: Base de données réinitialisée");
  }

  /// Vérifier si un token est valide (pour développement uniquement)
  static bool isValidToken(String? token) {
    if (token == null || !token.startsWith('mock.token.')) {
      return false;
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = utf8.decode(base64Decode(parts[2]));
      final tokenData = jsonDecode(payload);

      return tokenData['email'] != null;
    } catch (e) {
      return false;
    }
  }

  /// Obtenir le mode actuel de l'API (pour information)
  static String getApiMode() {
    return 'Développement Local';
  }

  /// Obtenir le chemin complet du fichier de données (pour debug)
  static Future<String> getDataFilePath() async {
    final file = await _getUsersFile();
    return file.path;
  }

  /// Lire le contenu brut du fichier de données (pour debug)
  static Future<String> getDataFileContent() async {
    try {
      final file = await _getUsersFile();
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return 'Le fichier n\'existe pas encore';
      }
    } catch (e) {
      return 'Erreur lors de la lecture: $e';
    }
  }

  /// Afficher les informations de debug dans la console
  static Future<void> debugFileInfo() async {
    await _loadUsers();
    final path = await getDataFilePath();
    final content = await getDataFileContent();

    debugPrint("=== DEBUG API FILE ===");
    debugPrint("Chemin du fichier: $path");
    debugPrint("Contenu du fichier:");
    debugPrint(content);
    debugPrint("Nombre d'utilisateurs en mémoire: ${_users.length}");
    debugPrint("======================");
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gestionnaire de Session
/// Gère le stockage sécurisé des tokens d'authentification
class SessionManager {
  // Configuration du stockage sécurisé avec options spécifiques pour Android et iOS
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  // Clé pour stocker le token d'authentification
  static const String _tokenKey = 'auth_token';

  /// Sauvegarder le token d'authentification de manière sécurisée
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Récupérer le token d'authentification stocké
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Supprimer le token d'authentification (déconnexion)
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Vérifier si l'utilisateur est connecté (a un token valide)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

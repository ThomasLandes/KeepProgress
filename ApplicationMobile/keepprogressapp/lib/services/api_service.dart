import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:keepprogressapp/models/user_model.dart';
import 'package:keepprogressapp/services/session_manager.dart';

/// Service API
/// Gère toutes les communications avec l'API backend PHP
class ApiService {
  // URL de base de l'API (changer selon votre VPS)
  static const String baseUrl = 'http://84.235.238.246/keepprogress_api';

  /// Méthode helper pour obtenir les en-têtes avec authentification
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await SessionManager.getToken();
    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  //////////////////
  // INSCRIPTION  //
  //////////////////
  /// Inscrire un nouvel utilisateur
  /// Retourne: (succès, message, token)
  static Future<(bool, String, String?)> register(User user, String password) async {
    final url = Uri.parse("$baseUrl/auth/register.php");

    // Préparer les données à envoyer
    final body = jsonEncode({'nom': user.nom, 'age': user.age, 'email': user.email, 'password': password});

    try {
      // Envoyer la requête POST à l'API
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);

      String message = "";
      bool success = false;
      String? token;

      // Parser la réponse JSON
      if (response.headers['content-type']?.contains('application/json') == true) {
        final data = jsonDecode(response.body);
        message = data['message'] ?? 'Erreur inconnue';
        success = data['success'] ?? false;
        token = data['token'];
      }

      return (success, message, token);
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
    final url = Uri.parse("$baseUrl/auth/login.php");

    try {
      // Envoyer la requête de connexion
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      String message = "";
      bool success = false;
      String? token;

      if (response.headers['content-type']?.contains('application/json') == true) {
        final data = jsonDecode(response.body);
        message = data['message'] ?? 'Erreur inconnue';
        success = data['success'] ?? false;
        token = data['token'];
      }

      return (success, message, token);
    } catch (e) {
      return (false, 'Erreur lors de la requête : $e', null);
    }
  }

  ///////////
  //LOGOUT///
  ///////////
  static Future<bool> logout() async {
    try {
      // Clear the stored token
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
    final url = Uri.parse("$baseUrl$endpoint");
    final headers = await _getAuthHeaders();

    try {
      final response = await http.get(url, headers: headers);
      return response;
    } catch (e) {
      debugPrint("Erreur authenticated GET: $e");
      return null;
    }
  }

  ////////////////////////
  ///GET USER PROFILE/////
  ////////////////////////
  static Future<User?> getUserProfile() async {
    final response = await authenticatedGet('/user/profile.php');

    if (response?.statusCode == 200) {
      try {
        final data = jsonDecode(response!.body);

        if (data['success'] == true && data['data'] != null && data['data']['user'] != null) {
          final userData = data['data']['user'];
          return User(nom: userData['nom'] ?? '', age: userData['age'] ?? 0, email: userData['email'] ?? '');
        }
      } catch (e) {
        debugPrint("Erreur parsing user profile: $e");
      }
    }

    return null;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Remplace cette URL par celle de webhook.site pour tester
  static const String baseUrl =
      'https://webhook.site/f8572790-5cee-43ab-9509-936c56c458e9'; // à personnaliser

  static Future<bool> register({
    required String nom,
    required int age,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(baseUrl);

    final body = jsonEncode({
      'nom': nom,
      'age': age,
      'email': email,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Log des infos utiles
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Body sent: $body');
      debugPrint('Response body: ${response.body}');

      // Si on reçoit un 200 ou 201, on considère la requête comme OK
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Erreur lors de l\'envoi de la requête: $e');
      return false;
    }
  }

  static Future<bool> login(String email, String password) async {
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Connexion réussie');
        return true;
      } else {
        debugPrint('Échec de la connexion : ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Erreur lors de la requête : $e');
      return false;
    }
  }
}

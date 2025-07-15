import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:keepprogressapp/models/session_model.dart';
import 'package:keepprogressapp/models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/keepprogressapp/api';

  ////////////
  //REGISTER//
  ////////////
  static Future<bool> register({
    required String nom,
    required int age,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final body = jsonEncode({'nom': nom, 'age': age, 'email': email, 'password': password});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Body sent: $body');
      debugPrint('Response body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Erreur lors de l\'envoi de la requête: $e');
      return false;
    }
  }

  /////////
  //LOGIN//
  /////////
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

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

  /////////////////////
  ///FORGOT PASSWORD///
  /////////////////////
  static Future<bool> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Erreur forgotPassword: $e");
      return false;
    }
  }

  ////////////////////
  ///GET USER BY ID///
  ////////////////////
  static Future<User?> getUserById(int userId) async {
    final url = Uri.parse('$baseUrl/users/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return User.fromJson(userData);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Erreur getUserById: $e');
      return null;
    }
  }

  static Future<List<Session>> fetchSessions(int userId) async {
    final url = Uri.parse('$baseUrl/sessions/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => Session.fromJson(e)).toList();
    } else {
      throw Exception("Erreur chargement séances");
    }
  }

  static Future<bool> addSession(int userId, Session session) async {
    final url = Uri.parse('$baseUrl/sessions');
    final sessionData = session.toJson();
    sessionData['userId'] = userId; // Add userId to the session data

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sessionData),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> deleteSession(int sessionId) async {
    final url = Uri.parse('$baseUrl/sessions/$sessionId');
    final response = await http.delete(url);
    return response.statusCode == 200;
  }
}

import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('KeepProgress API Tests', () {
    const String baseUrl = 'http://84.235.238.246/keepprogress_api';
    late String testEmail;
    late String testPassword;
    String? userToken;
    int? userId;

    setUpAll(() {
      // Génère un email unique pour chaque test
      final random = Random();
      testEmail = 'test_${random.nextInt(99999)}@example.com';
      testPassword = 'TestPassword123';

      print('🧪 Démarrage des tests API KeepProgress');
      print('📧 Email de test: $testEmail');
      print('🌐 API URL: $baseUrl');
    });

    tearDownAll(() async {
      // Nettoyage : suppression de l'utilisateur de test
      if (userId != null) {
        print('🗑️ Nettoyage de l\'utilisateur ID: $userId');
        // Note: La suppression se fera via la base de données
        // car nous n'avons pas d'endpoint DELETE user dans l'API
      }
    });

    test('1. 📝 Inscription - Crée un utilisateur de test', () async {
      print('\n[TEST 1/6] Test d\'inscription...');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nom': 'Test User', 'age': 25, 'email': testEmail, 'password': testPassword}),
      );

      expect(response.statusCode, 200);

      final data = jsonDecode(response.body);
      expect(data['success'], true);
      expect(data['user']['email'], testEmail);

      userId = data['user']['id'];
      print('✅ Inscription réussie - User ID: $userId');
    });

    test('2. 🔐 Connexion - Obtient un token', () async {
      print('\n[TEST 2/6] Test de connexion...');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': testEmail, 'password': testPassword}),
      );

      expect(response.statusCode, 200);

      final data = jsonDecode(response.body);
      expect(data['success'], true);
      expect(data['token'], isNotNull);

      userToken = data['token'];
      print('✅ Connexion réussie - Token: ${userToken!.substring(0, 30)}...');
    });

    test('3. 👤 Profil - Récupère les données utilisateur', () async {
      print('\n[TEST 3/6] Test de récupération du profil...');

      expect(userToken, isNotNull, reason: 'Token requis pour ce test');

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile.php'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $userToken'},
      );

      expect(response.statusCode, 200);

      final data = jsonDecode(response.body);
      expect(data['success'], true);
      expect(data['data']['user']['email'], testEmail);
      expect(data['data']['user']['nom'], 'Test User');

      print('✅ Profil récupéré - Nom: ${data['data']['user']['nom']}');
    });

    test('4. 🚪 Déconnexion - Ferme la session', () async {
      print('\n[TEST 4/6] Test de déconnexion...');

      expect(userToken, isNotNull, reason: 'Token requis pour ce test');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout.php'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $userToken'},
      );

      expect(response.statusCode, 200);

      final data = jsonDecode(response.body);
      expect(data['success'], true);

      print('✅ Déconnexion réussie');
    });

    test('5. 🔒 Sécurité - Teste le rejet des tokens invalides', () async {
      print('\n[TEST 5/6] Test de sécurité...');

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile.php'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer invalid_token_123'},
      );

      // Doit être rejeté avec une erreur 401 ou une réponse d'erreur
      expect(response.statusCode, anyOf([401, 200]));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        expect(data['success'], false, reason: 'Token invalide doit être rejeté');
      }

      print('✅ Token invalide correctement rejeté');
    });

    test('6. 🧹 Final - Vérification de l\'état final', () async {
      print('\n[TEST 6/6] Test final...');

      // Test simple pour s'assurer que l'API est toujours accessible
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': 'nonexistent@test.com', 'password': 'wrong'}),
      );

      expect(response.statusCode, anyOf([400, 422, 200]));
      print('✅ API toujours fonctionnelle après tous les tests');
      print('\n🎉 TOUS LES TESTS TERMINÉS !');
    });
  });
}

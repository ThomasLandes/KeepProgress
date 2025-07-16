import 'package:flutter/material.dart';
import 'package:keepprogressapp/services/session_manager.dart';
import 'package:keepprogressapp/services/api_service.dart';
import 'package:keepprogressapp/pages/dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkUserConnection();
  }

  /// Vérifier si l'utilisateur est déjà connecté
  /// Si oui, le rediriger vers le dashboard
  Future<void> _checkUserConnection() async {
    final isLoggedIn = await SessionManager.isLoggedIn();

    if (isLoggedIn) {
      // Essayer de récupérer le profil utilisateur
      final userData = await ApiService.getUserProfile();

      if (mounted) {
        if (userData != null) {
          // Rediriger vers le dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage(user: userData)),
          );
          return;
        } else {
          // Token invalide, le nettoyer
          await SessionManager.clearToken();
        }
      }
    }

    // Arrêter le loading si toujours sur cette page
    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Afficher un loader pendant la vérification
    if (_isChecking) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Vérification de la connexion...'),
            ],
          ),
        ),
      );
    }

    // Afficher la page d'accueil normale si pas connecté
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenue sur KeepCool'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenue !', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              child: Text('Se connecter'),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              child: Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}

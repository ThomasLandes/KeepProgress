import 'package:flutter/material.dart';
import 'package:keepprogress/services/session_manager.dart';
import 'package:keepprogress/services/api_service.dart';
import 'package:keepprogress/pages/dashboard_page.dart';

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
            SizedBox(height: 40),
            // Bouton de debug pour voir les données
            if (true) // Vous pouvez mettre false pour masquer en production
              ElevatedButton(
                onPressed: () async {
                  await ApiService.debugFileInfo();
                  final path = await ApiService.getDataFilePath();
                  final content = await ApiService.getDataFileContent();

                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Données API'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Chemin du fichier:', style: TextStyle(fontWeight: FontWeight.bold)),
                                SelectableText(path),
                                SizedBox(height: 16),
                                Text('Contenu:', style: TextStyle(fontWeight: FontWeight.bold)),
                                SelectableText(content),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Fermer')),
                          ],
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: Size(double.infinity, 40),
                ),
                child: Text('🔍 Debug - Voir données API'),
              ),
          ],
        ),
      ),
    );
  }
}

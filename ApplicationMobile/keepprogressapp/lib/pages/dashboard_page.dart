import 'package:flutter/material.dart';
import 'package:keepprogressapp/models/user_model.dart';
import 'package:keepprogressapp/services/api_service.dart';

class DashboardPage extends StatelessWidget {
  final User user;
  const DashboardPage({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    // Déconnecter l'utilisateur
    await ApiService.logout();

    // Vérifier si le widget est toujours monté avant d'utiliser context
    if (context.mounted) {
      // Retourner à la page d'accueil
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenue ${user.nom}'),
        automaticallyImplyLeading: false, // Enlever le bouton retour
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dashboard en cours de développement',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size(200, 50),
              ),
              child: Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}

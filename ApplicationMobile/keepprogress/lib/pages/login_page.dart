import 'package:flutter/material.dart';
import 'package:keepprogress/services/session_manager.dart';
import 'package:keepprogress/services/api_service.dart';

/// Page de Connexion
/// Permet à l'utilisateur de se connecter avec email et mot de passe
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Contrôleurs pour les champs de saisie
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  /// Gérer la tentative de connexion
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Appeler l'API de connexion
      (bool, String, String?) result = await ApiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      // Afficher le message de résultat
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.$2)));

      // Si connexion réussie et token reçu, sauvegarder le token et rediriger vers la page de base
      if (result.$1 && result.$3 != null) {
        await SessionManager.saveToken(result.$3!);
        // Vérifier si le widget est toujours monté avant d'utiliser context
        if (mounted) {
          // Rediriger vers la page de base qui va vérifier la connexion
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) => value != null && value.contains('@') ? null : 'Email invalide',
              ),
              SizedBox(height: 20),

              // Mot de passe
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) => value != null && value.length >= 6 ? null : 'Mot de passe trop court',
              ),

              SizedBox(height: 20),

              // Bouton connexion
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

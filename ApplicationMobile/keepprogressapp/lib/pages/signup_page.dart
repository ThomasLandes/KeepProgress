import 'package:flutter/material.dart';
import 'package:keepprogressapp/models/user_model.dart';
import 'package:keepprogressapp/services/session_manager.dart';
import '../services/api_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        User newUser = User(
          nom: _nomController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          email: _emailController.text.trim(),
        );
        (bool, String, String?) result = await ApiService.register(newUser, _passwordController.text.trim());

        if (!mounted) return;

        if (result.$1 && result.$3 != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.$2)));
          }
          await SessionManager.saveToken(result.$3!);
          // Vérifier si le widget est toujours monté avant d'utiliser context
          if (mounted) {
            // Rediriger vers la page de base qui va vérifier la connexion
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        } else {
          setState(() {
            _errorMessage = result.$2;
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Une erreur s’est produite : $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_errorMessage != null) Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Entrez un nom' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Âge', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Entrez votre âge' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) =>
                    value != null && value.contains('@') && value.contains('.') ? null : 'Email invalide',
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) => value!.length < 8 ? 'Mot de passe trop court' : null,
              ),
              SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(onPressed: _register, child: Text('Créer un compte')),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
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
        final success = await ApiService.register(
          nom: _nomController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Compte créé avec succès')));
          Navigator.pop(context);
        } else {
          setState(() {
            _errorMessage = 'Erreur lors de la création du compte';
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
                    value != null && value.contains('@') ? null : 'Email invalide',
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Mot de passe trop court' : null,
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

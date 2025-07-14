import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _message;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final success = await ApiService.forgotPassword(_emailController.text.trim());

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _message = success
          ? "Un email de réinitialisation a été envoyé."
          : "Erreur lors de l'envoi. Veuillez réessayer.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mot de passe oublié')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Saisissez l'adresse e-mail associée à votre compte.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) =>
                    value != null && value.contains('@') ? null : 'Email invalide',
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(onPressed: _submit, child: Text('Continuer')),
              if (_message != null) ...[
                SizedBox(height: 20),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.startsWith("Erreur") ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

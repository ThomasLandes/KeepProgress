import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenue sur KeepCool'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue !',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Se connecter'),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('S’inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}

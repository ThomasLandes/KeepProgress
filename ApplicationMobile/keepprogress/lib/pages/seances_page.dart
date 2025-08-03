import 'package:flutter/material.dart';

class SeancesPage extends StatelessWidget {
  const SeancesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Séances'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'Page des séances\n(À implémenter)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Ajouter une nouvelle séance
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:keepprogressapp/models/user_model.dart';

class DashboardPage extends StatelessWidget {
  final User user;
  const DashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenue ${user.nom}')),
      body: Center(child: Text('Dashboard en cours de développement')),
    );
  }
}

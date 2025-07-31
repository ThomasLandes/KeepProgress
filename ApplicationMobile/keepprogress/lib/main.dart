import 'package:flutter/material.dart';
import 'package:keepprogress/pages/home_page.dart';
import 'package:keepprogress/pages/login_page.dart';
import 'package:keepprogress/pages/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Toujours démarrer par la HomePage qui va gérer la vérification de connexion
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KeepCool App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, visualDensity: VisualDensity.adaptivePlatformDensity),
      home: const HomePage(), // Toujours démarrer par la HomePage
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
      },
    );
  }
}

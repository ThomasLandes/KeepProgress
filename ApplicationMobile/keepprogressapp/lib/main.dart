import 'package:flutter/material.dart';
import 'package:keepprogressapp/pages/forgot_password_page.dart';
import 'package:keepprogressapp/pages/home_page.dart';
import 'package:keepprogressapp/pages/login_page.dart';
import 'package:keepprogressapp/pages/signup_page.dart';
import 'package:keepprogressapp/services/api_service.dart';
import 'package:keepprogressapp/services/user_session_manager.dart';
import 'package:keepprogressapp/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  UserSessionManager.saveUserId(1);

  // Lecture session locale
  final userId = await UserSessionManager.getUserId();

  Widget startPage;

  if (userId != null) {
    final userData = await ApiService.getUserById(userId);

    if (userData != null) {
      startPage = DashboardPage(user: userData);
    } else {
      await UserSessionManager.clearUser();
      startPage = const HomePage();
    }
  } else {
    startPage = const HomePage();
  }

  runApp(MyApp(startPage: startPage));
}

class MyApp extends StatelessWidget {
  final Widget startPage;

  const MyApp({super.key, required this.startPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KeepCool App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: startPage,
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/forgot_password_page': (context) => const ForgotPasswordPage(),
      },
    );
  }
}

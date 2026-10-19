// lib/main.dart  (VERSION ADMIN)
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Charge la session existante (et déconnecte si le compte n'est pas admin)
  await AuthService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Délicia Admin',
      theme: AppTheme.light,
      // Admin déjà connecté -> menu, sinon -> login
      home: AuthService.instance.currentUser != null
          ? const MainShell()
          : const LoginPage(),
    );
  }
}
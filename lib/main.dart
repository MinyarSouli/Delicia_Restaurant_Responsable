// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/welcome_page.dart';
import 'theme/app_theme.dart';

/// Point d'entrée de l'application.
///
/// On doit initialiser Firebase AVANT d'afficher quoi que ce soit.
/// C'est pourquoi main() est une fonction asynchrone (async/await).
void main() async {
  // Étape 1 : s'assurer que Flutter est prêt à recevoir des appels natifs
  WidgetsFlutterBinding.ensureInitialized();

  // Étape 2 : démarrer Firebase avec la configuration du projet
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Étape 3 : attendre le premier état d'authentification Firebase
  // (connecté ou déconnecté) pour éviter un clignotement à l'ouverture
  await AuthService.instance.init();

  // Étape 4 : afficher l'application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Délicia', // titre de l'application
      theme: AppTheme.light, // thème personnalisé
      home: const WelcomePage(), // démarrage par la page d'accueil
    );
  }
}

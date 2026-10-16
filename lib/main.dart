import 'package:flutter/material.dart';

import 'screens/carte_page.dart';
import 'theme/app_theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Délicia', // titre de l'application
      theme: AppTheme.light, // thème personnalisé
      home: const CartePage(),
    );
  }
}

// lib/theme/app_colors.dart
// Palette de couleurs de l'application Délicia
import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales – orange brûlé chaleureux
  static const Color orangePrimary = Color(0xFFC2561C); // orange principal
  static const Color orangeDark = Color(0xFFA44519);    // orange foncé

  // Dégradé de fond pêche (du haut vers le bas de l'écran)
  static const Color peachTop    = Color(0xFFFDE8D0);
  static const Color peachBottom = Color(0xFFF9C79A);

  // Bordure pêche légère pour les chips non sélectionnés
  static const Color peachBorder = Color(0xFFF0C9A4);

  // Couleurs des cartes et du texte
  static const Color cardCream    = Color(0xFFFFF4E6); // fond crème des cartes
  static const Color textBrown    = Color(0xFF3A2216); // texte principal
  static const Color textSecondary = Color(0xFF8A6A55); // texte secondaire gris-brun

  // Couleurs d'état
  static const Color error   = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF4C8C4A);
}

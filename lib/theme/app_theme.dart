// lib/theme/app_theme.dart
// Thème personnalisé pour l'application Délicia
import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  // Thème clair utilisant Material 3
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    // Construction du ColorScheme à partir de la palette définie dans AppColors
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.orangePrimary,
      onPrimary: Colors.white,
      secondary: AppColors.orangeDark,
      onSecondary: Colors.white,
      background: AppColors.peachTop,
      onBackground: AppColors.textBrown,
      surface: AppColors.cardCream,
      onSurface: AppColors.textBrown,
      error: AppColors.error,
      onError: Colors.white,
    ),
    // Thèmes des composants
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(54)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.cardCream,
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.orangePrimary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: AppColors.cardCream,
      elevation: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.cardCream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      labelStyle: TextStyle(color: AppColors.textBrown),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textBrown,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.textBrown),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      // aucune configuration spécifique, on garde le style Material 3 par défaut
    ),
  );
}

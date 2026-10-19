// lib/theme/app_theme.dart
// Thème personnalisé pour l'application Délicia
// C'est ici qu'on centralise TOUS les styles visuels.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  // -------------------------------------------------------
  // Thème clair utilisant Material 3
  // -------------------------------------------------------
  static ThemeData get light {
    // Base de la typographie avec Nunito pour tout le texte
    final baseTextTheme = GoogleFonts.nunitoTextTheme();

    return ThemeData(
      useMaterial3: true,

      // Police par défaut Nunito
      fontFamily: GoogleFonts.nunito().fontFamily,

      // Transitions de pages fluides (fondu / glissement doux)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Palette de couleurs centralisée
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.orangePrimary,
        onPrimary: Colors.white,
        secondary: AppColors.orangeDark,
        onSecondary: Colors.white,
        background: AppColors.peachTop,
        onBackground: AppColors.textBrown,
        surface: AppColors.cardCream, // fond de carte = crème
        onSurface: AppColors.textBrown,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // Police Nunito pour tout le texte de l'application
      textTheme: baseTextTheme.copyWith(
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.textBrown),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.textBrown),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: AppColors.textBrown),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: AppColors.textBrown),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: AppColors.textBrown),
      ),

      // ----- Bouton plein -----
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(54)),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          side: WidgetStateProperty.all(BorderSide.none),
        ),
      ),

      // ----- Bouton avec contour -----
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),

      // ----- Bouton texte -----
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),

      // ----- Champ de texte -----
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.cardCream,
        filled: true,
        hintStyle: GoogleFonts.nunito(color: AppColors.textSecondary),
        labelStyle: GoogleFonts.nunito(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.orangePrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        prefixIconColor: AppColors.textSecondary,
      ),

      // ----- Carte (Card) -----
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: AppColors.cardCream,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),

      // ----- Puces de catégories (Chip / ChoiceChip) -----
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardCream,
        selectedColor: AppColors.orangePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: AppColors.peachBorder, width: 1),
        ),
        labelStyle: GoogleFonts.nunito(
          color: AppColors.textBrown,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        showCheckmark: false,
        side: const BorderSide(color: AppColors.peachBorder, width: 1),
      ),

      // ----- Barre du haut (AppBar) -----
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          color: AppColors.textBrown,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.textBrown),
      ),

      // ----- SnackBar flottant arrondi -----
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textBrown,
        contentTextStyle: GoogleFonts.nunito(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ----- Boîtes de dialogue -----
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),

      // ----- Barre de navigation -----
      navigationBarTheme: const NavigationBarThemeData(),
    );
  }
}

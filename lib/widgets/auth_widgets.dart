import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

// =====================================================================
// AUTH WIDGETS – composants partagés entre LoginPage et RegisterPage
// =====================================================================

/// En-tête commun aux pages Connexion et Inscription.
/// Bandeau dégradé orange → orange foncé, coins inférieurs arrondis.
/// Contient le logo « Délicia » en police script, un titre et un sous-titre.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBack;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    // Hauteur de la zone de sécurité en haut (barre de status)
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, top + 12, 24, 36),
      decoration: const BoxDecoration(
        // Dégradé orange brûlé → orange foncé
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.orangePrimary, AppColors.orangeDark],
        ),
        // Coins arrondis seulement en bas
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        children: [
          // ----- Bouton retour (optionnel) -----
          SizedBox(
            height: 48,
            child: Align(
              alignment: Alignment.centerLeft,
              child: showBack
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      tooltip: 'Retour',
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
            ),
          ),

          // ----- Logo "Délicia" dans un cercle blanc -----
          // Cercle blanc avec le texte "Délicia" en police script orange
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              // Légère ombre sous le cercle
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                // Même police Pacifico que sur la page menu
                'D',
                style: GoogleFonts.pacifico(
                  fontSize: 36,
                  color: AppColors.orangePrimary,
                  height: 1.1,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ----- Titre (ex. « Bon retour ! ») -----
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // ----- Sous-titre -----
          // Couleur crème opacité 0.9 pour être lisible sur orange
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              // Crème clair bien lisible sur orange brûlé
              color: const Color(0xFFFFF4E6).withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// FONCTION authDecoration
// Style commun des champs de saisie :
//   - fond très légèrement crème (#FFF9F2)
//   - bordure pêche fine (#F0C9A4)
//   - rayon 16
//   - bordure orange au focus
//   - bordure rouge sur erreur
// Toutes les validations restent dans les pages (non modifiées).
// =====================================================================
InputDecoration authDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
  String? hint,
  Widget? suffix,
}) {
  // Couleur de fond : légèrement plus claire que le fond de page
  const fillColor = Color(0xFFFFF9F2);
  // Bordure pêche légère
  const peachBorder = AppColors.peachBorder;

  // Fonction utilitaire pour créer une bordure arrondie
  OutlineInputBorder makeBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.textSecondary),
    suffixIcon: suffix,
    filled: true,
    fillColor: fillColor, // fond très légèrement crème
    // Bordure au repos : pêche fine
    border: makeBorder(peachBorder),
    enabledBorder: makeBorder(peachBorder),
    // Bordure orange au focus
    focusedBorder: makeBorder(AppColors.orangePrimary, 2),
    // Bordure rouge sur erreur
    errorBorder: makeBorder(AppColors.error),
    focusedErrorBorder: makeBorder(AppColors.error, 2),
  );
}

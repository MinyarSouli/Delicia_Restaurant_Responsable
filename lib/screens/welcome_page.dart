import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/menu_data.dart';
import '../theme/app_colors.dart';
import '../widgets/dish_image.dart';
import 'main_shell.dart';

/// Écran d'accueil chaleureux de la boulangerie-café Délicia.
/// Présente un collage moodboard de 3 photos de plats populaires,
/// le logo « Délicia » en police script Pacifico, la phrase d'accroche
/// et le bouton d'entrée « Découvrir la carte ».
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 3 premiers plats populaires pour le collage
    final populars = menuDishes.where((d) => d.isPopular).take(3).toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.peachTop, AppColors.peachBottom],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ===== COLLAGE MOODBOARD 3 PHOTOS DE PLATS =====
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      child: SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // 1ère photo : gauche, inclinée -6°, taille 120x150
                            if (populars.isNotEmpty)
                              Positioned(
                                left: 16,
                                top: 20,
                                child: Transform.rotate(
                                  angle: -0.1, // ~ -6 degrés
                                  child: Container(
                                    width: 120,
                                    height: 155,
                                    decoration: BoxDecoration(
                                      color: AppColors.cardCream,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF3A2216)
                                              .withValues(alpha: 0.16),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: DishImage(
                                        path: populars[0].image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // 2ème photo : droite, inclinée +7°, taille 115x145
                            if (populars.length > 1)
                              Positioned(
                                right: 16,
                                top: 28,
                                child: Transform.rotate(
                                  angle: 0.12, // ~ +7 degrés
                                  child: Container(
                                    width: 115,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: AppColors.cardCream,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF3A2216)
                                              .withValues(alpha: 0.15),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: DishImage(
                                        path: populars[1].image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // 3ème photo : centrale, plus grande (140x180), droite, en avant-plan
                            if (populars.length > 2)
                              Positioned(
                                top: 4,
                                child: Container(
                                  width: 140,
                                  height: 185,
                                  decoration: BoxDecoration(
                                    color: AppColors.cardCream,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF3A2216)
                                            .withValues(alpha: 0.22),
                                        blurRadius: 22,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(7),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(21),
                                    child: DishImage(
                                      path: populars[2].image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ===== TEXTES ET LOGO =====
                    Column(
                      children: [
                        // Logo « Délicia » avec la même police script que le menu
                        Text(
                          'Délicia',
                          style: GoogleFonts.pacifico(
                            fontSize: 44,
                            color: AppColors.orangePrimary,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Boulangerie, Pâtisserie & Café gourmand',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBrown,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Savourez nos créations artisanales préparées avec passion chaque jour.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ===== BOUTON D'ACCUEIL =====
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const MainShell(),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              backgroundColor: AppColors.orangePrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Découvrir la carte',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

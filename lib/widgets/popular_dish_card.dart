import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../widgets/dish_image.dart';
import '../theme/app_colors.dart';

/// Carte verticale pour afficher un plat populaire.
/// Largeur fixe : 150 px.
/// Structure : image arrondie en haut (hauteur 100), nom, prix orange, bouton + rond.
class PopularDishCard extends StatelessWidget {
  final Dish dish;
  final VoidCallback onQuickAdd;

  const PopularDishCard({
    Key? key,
    required this.dish,
    required this.onQuickAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 150, // largeur fixe de la carte verticale
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardCream, // fond crème
          borderRadius: BorderRadius.circular(20),
          // Ombre chaude et douce (brun, alpha 0.12, flou 16, décalage 0,6)
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3A2216).withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ----- Image arrondie en haut -----
            ClipRRect(
              // Coins arrondis seulement en haut pour suivre la forme de la carte
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 100, // hauteur de l'image
                width: double.infinity,
                child: DishImage(path: dish.image),
              ),
            ),

            // ----- Texte et bouton -----
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nom du plat sur 1 ligne max
                  Text(
                    dish.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBrown,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Ligne : prix + bouton +
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Prix en orange
                      Text(
                        formatPrice(dish.price),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.orangePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Bouton + rond orange, icône blanche, taille 32 (zone tactile ≥ 48 via padding)
                      GestureDetector(
                        onTap: onQuickAdd,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.orangePrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

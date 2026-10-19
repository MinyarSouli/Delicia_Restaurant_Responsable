import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../widgets/dish_image.dart';
import '../theme/app_colors.dart';

/// Carte d'un plat du menu.
/// Structure : image 4/3 arrondie en haut, puis texte + bouton « + » en bas.
/// Le bouton « + » est rond, orange, 40 px, en bas à droite du bloc texte (PAS sur l'image).
/// Un tap sur la carte ouvre le détail du plat (avec animation Hero).
class DishCard extends StatelessWidget {
  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;

  const DishCard({
    super.key,
    required this.dish,
    required this.onTap,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      // Tap sur la carte = ouvrir le détail du plat
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardCream, // fond crème
          borderRadius: BorderRadius.circular(24),
          // Ombre chaude et douce : brun, alpha 0.12, flou 16, décalage 0,6
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
          children: [
            // ----- Image arrondie en haut au format 4/3 fixe -----
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: AspectRatio(
                aspectRatio: 4 / 3, // format 4/3
                child: Hero(
                  tag: 'dish-${dish.id}',
                  child: DishImage(path: dish.image),
                ),
              ),
            ),

            // ----- Bloc texte + bouton + en bas remplissant le reste -----
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom en gras sur 1 ligne
                    Text(
                      dish.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBrown,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Description sur 2 lignes max en gris-brun
                    Text(
                      dish.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.25,
                      ),
                    ),

                    const Spacer(),

                    // Ligne : prix + bouton + rond
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Prix en orange en gras
                        Expanded(
                          child: Text(
                            formatPrice(dish.price),
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.orangePrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Bouton « + » rond orange 40 px, icône blanche
                        GestureDetector(
                          onTap: onQuickAdd,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.orangePrimary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

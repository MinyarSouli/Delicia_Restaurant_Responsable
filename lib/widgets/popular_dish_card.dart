import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../widgets/dish_image.dart';

/// Carte horizontale pour un plat populaire.
/// Affiche l'image (rond), le nom, le prix et un bouton "+" d'ajout rapide.
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        onTap: () {}, // Le tap n'est pas utilisé ici, mais on peut le rediriger vers le détail si besoin.
        child: Row(
          children: [
            // Image ronde
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: DishImage(
                    path: dish.image,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Nom et prix
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dish.name,
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(dish.price),
                    style: textTheme.bodySmall?.copyWith(color: colors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Bouton +
            IconButton(
              icon: Icon(Icons.add, color: colors.onPrimary),
              color: colors.primary,
              onPressed: onQuickAdd,
              tooltip: 'Ajouter rapidement',
            ),
          ],
        ),
      ),
    );
  }
}

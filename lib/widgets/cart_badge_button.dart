import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';

/// Bouton du panier avec badge du nombre d'articles.
/// Le badge se met à jour automatiquement grâce à ListenableBuilder.
/// L'icône est un caddie (shopping_cart_outlined) de couleur orange.
/// Au clic : bascule sur l'onglet Panier sans empiler de nouvelle page.
class CartBadgeButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CartBadgeButton({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartService.instance,
      builder: (context, _) {
        final count = CartService.instance.itemCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Bouton principal : icône caddie orange
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.orangePrimary, // orange brûlé
              ),
              onPressed: () {
                if (onTap != null) {
                  onTap!();
                } else {
                  // Bascule sur l'onglet Panier de MainShell
                  NavigationService.instance.openCart();
                }
              },
            ),

            // Badge rouge avec le nombre d'articles (visible seulement si > 0)
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

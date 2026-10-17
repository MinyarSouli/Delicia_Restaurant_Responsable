import 'package:flutter/material.dart';
import '../services/cart_service.dart';

/// Bouton du panier avec badge du nombre d'articles.
/// Le badge se met à jour grâce à ListenableBuilder.
/// En cliquant, affiche un SnackBar "Le panier arrive bientôt".
class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: CartService.instance,
      builder: (context, _) {
        final count = CartService.instance.itemCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.shopping_bag_outlined, color: colors.primary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le panier arrive bientôt')),
                );
              },
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                  child: Text(
                    '$count',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

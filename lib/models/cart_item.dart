// lib/models/cart_item.dart
// ─────────────────────────────────────────────────────────────────────────────
// Modèle représentant un article dans le panier.
//
// Un CartItem encapsule :
//   • le [dish]        → le plat de base
//   • [supplements]    → les suppléments choisis par le client
//   • [quantity]       → nombre d'exemplaires commandés
//
// [key] est une clé unique dérivée du plat + des suppléments, permettant
// d'identifier un article de façon unique même si le même plat est commandé
// avec des suppléments différents.
// ─────────────────────────────────────────────────────────────────────────────
import '../models/dish.dart';

class CartItem {
  final Dish dish;
  final List<Supplement> supplements;
  final int quantity;

  const CartItem({
    required this.dish,
    required this.supplements,
    required this.quantity,
  });

  /// Clé unique : id du plat + noms des suppléments triés.
  /// Permet de différencier le même plat avec des options différentes.
  String get key {
    final suppNames = supplements.map((s) => s.name).toList()..sort();
    return '${dish.id}_${suppNames.join(',')}';
  }

  /// Prix total de la ligne = (prix plat + prix suppléments) × quantité.
  double get total {
    final suppTotal = supplements.fold(0.0, (sum, s) => sum + s.price);
    return (dish.price + suppTotal) * quantity;
  }

  /// Crée une copie avec une nouvelle quantité.
  CartItem copyWith({int? quantity, List<Supplement>? supplements}) {
    return CartItem(
      dish: dish,
      supplements: supplements ?? this.supplements,
      quantity: quantity ?? this.quantity,
    );
  }
}

import 'dish.dart';

/// Une ligne du panier : un plat, sa quantité et ses suppléments choisis.
class CartItem {
  final Dish dish;
  int quantity;
  final List<Supplement> supplements;

  CartItem({
    required this.dish,
    this.quantity = 1,
    this.supplements = const [],
  });

  /// Prix d'une unité : plat + suppléments.
  double get unitPrice =>
      dish.price + supplements.fold<double>(0, (sum, s) => sum + s.price);

  /// Prix de la ligne : prix unitaire x quantité.
  double get total => unitPrice * quantity;

  /// Identifiant de la ligne : même plat + mêmes suppléments = même ligne.
  String get key {
    final names = supplements.map((s) => s.name).toList()..sort();
    return '${dish.id}|${names.join(',')}';
  }
}

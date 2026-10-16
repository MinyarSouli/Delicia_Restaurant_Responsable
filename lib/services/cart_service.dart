import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/dish.dart';

/// Panier du client, gardé en mémoire.
///
/// ChangeNotifier : quand le panier change, les écrans qui l'écoutent
/// (avec ListenableBuilder) se mettent à jour automatiquement.
class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  /// Nombre total d'articles (en comptant les quantités).
  int get itemCount => _items.fold<int>(0, (sum, i) => sum + i.quantity);

  /// Total du panier (hors TVA pour l'instant).
  double get total => _items.fold<double>(0, (sum, i) => sum + i.total);

  void add(
    Dish dish, {
    int quantity = 1,
    List<Supplement> supplements = const [],
  }) {
    final newItem = CartItem(
      dish: dish,
      quantity: quantity,
      supplements: supplements,
    );

    // Même plat + mêmes suppléments : on augmente simplement la quantité
    final index = _items.indexWhere((i) => i.key == newItem.key);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

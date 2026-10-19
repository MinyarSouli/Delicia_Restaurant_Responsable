// lib/services/cart_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Service Panier — gestion locale de l'état du panier.
//
// CartService étend ChangeNotifier, ce qui lui permet d'être écouté via
// ListenableBuilder (dans cart_page.dart et cart_badge_button.dart).
// À chaque modification, les widgets abonnés se reconstruisent automatiquement.
//
// Opérations disponibles :
//   addItem(dish, supplements)    → ajoute ou incrémente un article
//   remove(item)                  → retire un article définitivement
//   restore(item)                 → ré-insère un article supprimé (Annuler)
//   increase(item)                → +1 sur la quantité
//   decrease(item)                → -1 (supprime si quantité = 1)
//   replaceSupplements(item, ...) → remplace les suppléments d'un article
//   clear()                       → vide complètement le panier
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/dish.dart';

class CartService extends ChangeNotifier {
  // ── Singleton ────────────────────────────────────────────────────────────
  CartService._();
  static final CartService instance = CartService._();

  // ── État interne ─────────────────────────────────────────────────────────
  final List<CartItem> _items = [];

  /// Liste des articles du panier (lecture seule depuis l'extérieur).
  List<CartItem> get items => List.unmodifiable(_items);

  /// Nombre total d'articles (somme des quantités).
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  /// Sous-total HT (sans TVA).
  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.total);

  // ─────────────────────────────────────────────────────────────────────────
  // addItem() – Ajoute un plat au panier (ou incrémente si déjà présent)
  // ─────────────────────────────────────────────────────────────────────────
  /// Si un article avec la même combinaison [dish] + [supplements] existe
  /// déjà, on incrémente sa quantité. Sinon, on crée un nouvel article.
  void addItem(Dish dish, {List<Supplement> supplements = const []}) {
    final newItem = CartItem(dish: dish, supplements: supplements, quantity: 1);
    final index = _items.indexWhere((i) => i.key == newItem.key);

    if (index >= 0) {
      // Article déjà présent → on incrémente la quantité
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
    } else {
      // Nouvel article → on l'ajoute en fin de liste
      _items.add(newItem);
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // remove() / restore() – Suppression avec possibilité d'annulation
  // ─────────────────────────────────────────────────────────────────────────
  /// Supprime définitivement [item] du panier.
  void remove(CartItem item) {
    _items.removeWhere((i) => i.key == item.key);
    notifyListeners();
  }

  /// Ré-insère [item] dans le panier (utilisé par le SnackBar "Annuler").
  void restore(CartItem item) {
    if (!_items.any((i) => i.key == item.key)) {
      _items.add(item);
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // increase() / decrease() – Modification de la quantité
  // ─────────────────────────────────────────────────────────────────────────
  /// Incrémente la quantité de [item] de 1.
  void increase(CartItem item) {
    final index = _items.indexWhere((i) => i.key == item.key);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
      notifyListeners();
    }
  }

  /// Décrémente la quantité de [item] de 1. Supprime si la quantité atteint 0.
  void decrease(CartItem item) {
    final index = _items.indexWhere((i) => i.key == item.key);
    if (index >= 0) {
      if (_items[index].quantity <= 1) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(
          quantity: _items[index].quantity - 1,
        );
      }
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // replaceSupplements() – Mise à jour des suppléments d'un article
  // ─────────────────────────────────────────────────────────────────────────
  /// Remplace les suppléments de [item] par [newSupplements].
  /// Utilisé par l'éditeur de suppléments dans le panier.
  void replaceSupplements(CartItem item, List<Supplement> newSupplements) {
    final index = _items.indexWhere((i) => i.key == item.key);
    if (index >= 0) {
      final qty = _items[index].quantity;
      _items[index] = CartItem(
        dish: item.dish,
        supplements: newSupplements,
        quantity: qty,
      );
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // clear() – Vide complètement le panier
  // ─────────────────────────────────────────────────────────────────────────
  /// Supprime tous les articles du panier (ex. après confirmation de commande).
  void clear() {
    _items.clear();
    notifyListeners();
  }
}

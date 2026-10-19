import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/dish.dart';
import '../config/app_config.dart';

/// Panier du client, gardé en mémoire.
///
/// ChangeNotifier : quand le panier change, les écrans qui l'écoutent
/// (avec ListenableBuilder) se mettent à jour automatiquement.
class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();

  final List<CartItem> _items = [];
  final List<CartItem> _removedItems = [];

  List<CartItem> get items => List.unmodifiable(_items);

  /// Nombre total d'articles (en comptant les quantités).
  int get itemCount => _items.fold<int>(0, (sum, i) => sum + i.quantity);

  /// Sous‑total HT du panier.
  double get subtotal => _items.fold<double>(0, (sum, i) => sum + i.total);

  /// Montant de la TVA (sous‑total * taux de TVA).
  double get vatAmount => double.parse((subtotal * vatRate).toStringAsFixed(3));

  /// Total TTC (sous‑total + TVA).
  double get totalWithVat =>
      double.parse((subtotal + vatAmount).toStringAsFixed(3));

  /// Ajoute un plat au panier. Si la même combinaison (plats + suppléments) existe déjà, incrémente la quantité.
  void add(Dish dish,
      {int quantity = 1, List<Supplement> supplements = const []}) {
    final newItem = CartItem(
      dish: dish,
      quantity: quantity,
      supplements: supplements,
    );
    final index = _items.indexWhere((i) => i.key == newItem.key);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  /// Augmente la quantité d'une ligne du panier déjà présente.
  void increase(CartItem item, [int delta = 1]) {
    final index = _items.indexWhere((i) => i.key == item.key);
    if (index >= 0) {
      _items[index].quantity += delta;
      notifyListeners();
    }
  }

  /// Diminue la quantité d'une ligne. Si la quantité atteint 0, la supprime.
  void decrease(CartItem item, [int delta = 1]) {
    final index = _items.indexWhere((i) => i.key == item.key);
    if (index >= 0) {
      final current = _items[index];
      if (current.quantity > delta) {
        current.quantity -= delta;
      } else {
        remove(current);
        return;
      }
      notifyListeners();
    }
  }

  /// Supprime une ligne du panier et la mémorise pour une éventuelle restauration.
  void remove(CartItem item) {
    final index = _items.indexWhere((i) => i.key == item.key);
    if (index >= 0) {
      final removed = _items.removeAt(index);
      _removedItems.add(removed);
      notifyListeners();
    }
  }

  /// Remplace les suppléments d'une ligne. Si une ligne avec la même clé (plat + nouveaux suppléments) existe déjà, fusionne les quantités.
  void replaceSupplements(CartItem item, List<Supplement> nouveauxSupplements) {
    final existingIndex = _items.indexWhere((i) => i.key == item.key);
    if (existingIndex == -1) return; // ligne inexistante
    final existing = _items[existingIndex];
    // Crée une nouvelle clé avec les nouveaux suppléments.
    final newItem = CartItem(
      dish: existing.dish,
      quantity: existing.quantity,
      supplements: nouveauxSupplements,
    );
    final newKeyIndex = _items.indexWhere((i) => i.key == newItem.key);
    if (newKeyIndex >= 0 && newKeyIndex != existingIndex) {
      // Fusion des quantités.
      _items[newKeyIndex].quantity += newItem.quantity;
      _items.removeAt(existingIndex);
    } else {
      // Remplace simplement les suppléments.
      _items[existingIndex] = newItem;
    }
    notifyListeners();
  }

  /// Restaure la dernière ligne supprimée (utile pour l'annulation).
  void restore(CartItem item) {
    final index = _removedItems.indexWhere((i) => i.key == item.key);
    if (index >= 0) {
      final restored = _removedItems.removeAt(index);
      final existingIndex = _items.indexWhere((i) => i.key == restored.key);
      if (existingIndex >= 0) {
        // Si la même ligne est déjà dans le panier, on fusionne les quantités.
        _items[existingIndex].quantity += restored.quantity;
      } else {
        _items.add(restored);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _removedItems.clear();
    notifyListeners();
  }
}

// lib/services/category_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Service Firestore pour la collection "categories".
// Fournit :
//   • watchCategories()        → Stream temps réel trié par ordre
//   • add(category)            → Ajoute une catégorie (Firestore génère l'id)
//   • update(category)         → Met à jour une catégorie existante
//   • delete(id)               → Supprime une catégorie par id
//   • seedIfEmpty()            → Importe les catégories par défaut si vide
// ─────────────────────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryService {
  // ── Singleton ────────────────────────────────────────────────────────────
  CategoryService._();
  static final CategoryService instance = CategoryService._();

  // ── Référence à la collection Firestore "categories" ─────────────────────
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('categories');

  // ─────────────────────────────────────────────────────────────────────────
  // watchCategories() – Écoute en TEMPS RÉEL la collection "categories"
  // ─────────────────────────────────────────────────────────────────────────
  /// Retourne un Stream qui émet une nouvelle liste de [MenuCategory] à chaque
  /// modification dans Firestore. Les catégories sont triées par champ "order".
  Stream<List<MenuCategory>> watchCategories() {
    return _col
        .orderBy('order')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => MenuCategory.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // add() – Ajoute une nouvelle catégorie
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> add(MenuCategory category) => _col.add(category.toMap());

  // ─────────────────────────────────────────────────────────────────────────
  // update() – Met à jour une catégorie existante
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> update(MenuCategory category) =>
      _col.doc(category.id).update(category.toMap());

  // ─────────────────────────────────────────────────────────────────────────
  // delete() – Supprime une catégorie
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> delete(String id) => _col.doc(id).delete();

  // ─────────────────────────────────────────────────────────────────────────
  // seedIfEmpty() – Importe les catégories par défaut si la collection est vide
  // ─────────────────────────────────────────────────────────────────────────
  /// Insère les 5 catégories d'origine dans Firestore si la collection
  /// "categories" est vide. Retourne le nombre de catégories importées (0 si
  /// déjà peuplée).
  Future<int> seedIfEmpty() async {
    final existing = await _col.limit(1).get();
    if (existing.docs.isNotEmpty) return 0;

    final defaults = [
      MenuCategory(id: '', name: 'Fast-food', iconCode: Icons.lunch_dining.codePoint, order: 0),
      MenuCategory(id: '', name: 'Plats',     iconCode: Icons.dinner_dining.codePoint, order: 1),
      MenuCategory(id: '', name: 'Café',      iconCode: Icons.coffee.codePoint,        order: 2),
      MenuCategory(id: '', name: 'Boissons',  iconCode: Icons.local_drink.codePoint,   order: 3),
      MenuCategory(id: '', name: 'Desserts',  iconCode: Icons.icecream.codePoint,      order: 4),
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (final c in defaults) {
      batch.set(_col.doc(), c.toMap());
    }
    await batch.commit();
    return defaults.length;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // getNextOrder() – Retourne l'ordre suivant pour une nouvelle catégorie
  // ─────────────────────────────────────────────────────────────────────────
  /// Lit toutes les catégories et retourne max(order) + 1.
  Future<int> getNextOrder() async {
    final snap = await _col.orderBy('order', descending: true).limit(1).get();
    if (snap.docs.isEmpty) return 0;
    return ((snap.docs.first.data()['order'] as int?) ?? 0) + 1;
  }
}

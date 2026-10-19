// lib/services/dish_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Service Firestore pour la collection "menu".
// Collecte les données de la collection "dishes" dans Firestore et fournit :
//   • watchDishes()       → Stream temps réel (équivalent onSnapshot)
//   • add(dish)           → Ajoute un plat dans Firestore
//   • update(dish)        → Met à jour un plat existant
//   • delete(id)          → Supprime un plat par son id de document
//   • seedIfEmpty(dishes) → Importe le menu local si Firestore est vide
// ─────────────────────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/dish.dart';

class DishService {
  // ── Singleton ────────────────────────────────────────────────────────────
  DishService._();
  static final DishService instance = DishService._();

  // ── Référence à la collection Firestore "dishes" ─────────────────────────
  // Toutes les opérations CRUD passent par cette référence.
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('dishes');

  // ─────────────────────────────────────────────────────────────────────────
  // watchDishes() – Écoute en TEMPS RÉEL la collection "dishes"
  // ─────────────────────────────────────────────────────────────────────────
  /// Retourne un Stream qui émet une nouvelle liste de [Dish] à CHAQUE
  /// modification dans Firestore (ajout, modification, suppression).
  ///
  /// C'est l'équivalent Flutter/Dart du `onSnapshot` de Firebase JS.
  /// Les plats sont triés par nom (A → Z).
  Stream<List<Dish>> watchDishes() {
    return _col
        .orderBy('name') // tri alphabétique par nom
        .snapshots()     // retourne un Stream<QuerySnapshot>
        .map(            // convertit chaque snapshot en List<Dish>
          (snap) => snap.docs
              .map((doc) => Dish.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // add() – Ajoute un nouveau plat (Firestore génère l'id automatiquement)
  // ─────────────────────────────────────────────────────────────────────────
  /// Enregistre [dish] dans Firestore. L'id du document est auto-généré.
  /// Les champs sauvegardés : name, description, price, category, image,
  /// isPopular, supplements.
  Future<void> add(Dish dish) => _col.add(dish.toMap());

  // ─────────────────────────────────────────────────────────────────────────
  // update() – Met à jour un plat existant
  // ─────────────────────────────────────────────────────────────────────────
  /// Met à jour le document Firestore dont l'id correspond à [dish.id].
  /// Utilise update() (et non set()) pour ne remplacer que les champs fournis.
  Future<void> update(Dish dish) => _col.doc(dish.id).update(dish.toMap());

  // ─────────────────────────────────────────────────────────────────────────
  // delete() – Supprime un plat
  // ─────────────────────────────────────────────────────────────────────────
  /// Supprime définitivement le document Firestore portant l'id [id].
  Future<void> delete(String id) => _col.doc(id).delete();

  // ─────────────────────────────────────────────────────────────────────────
  // seedIfEmpty() – Import initial du menu depuis menu_data.dart
  // ─────────────────────────────────────────────────────────────────────────
  /// Si la collection "dishes" est VIDE, importe en batch tous les [dishes]
  /// fournis (issus de menu_data.dart). Conserve les ids fixes pour que les
  /// paniers clients en cours ne soient pas cassés.
  ///
  /// Retourne le nombre de plats importés (0 si déjà peuplé).
  Future<int> seedIfEmpty(List<Dish> dishes) async {
    // Vérifie si la collection est déjà peuplée (lecture d'un seul doc)
    final existing = await _col.limit(1).get();
    if (existing.docs.isNotEmpty) return 0;

    // Batch write pour importer tous les plats en une seule transaction
    final batch = FirebaseFirestore.instance.batch();
    for (final d in dishes) {
      batch.set(_col.doc(d.id), d.toMap());
    }
    await batch.commit();
    return dishes.length;
  }
}
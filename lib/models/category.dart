// lib/models/category.dart
// ─────────────────────────────────────────────────────────────────────────────
// Modèle d'une catégorie du menu, stockée dans Firestore (collection "categories").
// Chaque catégorie a un nom affiché dans les chips et un code d'icône Material.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class MenuCategory {
  final String id;       // id du document Firestore (vide si non encore sauvegardé)
  final String name;     // ex: "Fast-food", "Plats", "Café"...
  final int iconCode;    // code point de l'icône Material (Icons.xxx.codePoint)
  final int order;       // ordre d'affichage dans les chips (0, 1, 2, ...)

  const MenuCategory({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.order,
  });

  /// Icône Material reconstituée depuis le code point.
  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  // ── Firestore → objet ──────────────────────────────────────────────────────
  factory MenuCategory.fromMap(String id, Map<String, dynamic> map) =>
      MenuCategory(
        id: id,
        name: (map['name'] as String?) ?? '',
        iconCode: (map['iconCode'] as int?) ?? Icons.category.codePoint,
        order: (map['order'] as int?) ?? 0,
      );

  // ── Objet → Firestore ──────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
        'name': name,
        'iconCode': iconCode,
        'order': order,
      };

  // ── Copie avec modification ────────────────────────────────────────────────
  MenuCategory copyWith({
    String? id,
    String? name,
    int? iconCode,
    int? order,
  }) =>
      MenuCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        iconCode: iconCode ?? this.iconCode,
        order: order ?? this.order,
      );
}

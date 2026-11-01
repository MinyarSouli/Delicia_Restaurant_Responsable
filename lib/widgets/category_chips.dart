// lib/widgets/category_chips.dart
// ─────────────────────────────────────────────────────────────────────────────
// Widget affichant les puces de catégories sous forme de ChoiceChip.
// Les catégories sont lues en temps réel depuis Firestore via CategoryService.
//
// Non sélectionné : fond crème, bordure pêche.
// Sélectionné : fond orange, texte blanc.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/category_service.dart';
import '../theme/app_colors.dart';

/// Widget de chips de catégories connecté à Firestore en temps réel.
///
/// [selectedIndex] : index de la catégorie active dans la liste Firestore.
/// [onSelect]      : callback appelé avec le nouvel index sélectionné.
/// [searching]     : si true, aucune puce n'est mise en évidence (mode recherche).
class CategoryChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool searching;

  const CategoryChips({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.searching,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MenuCategory>>(
      stream: CategoryService.instance.watchCategories(),
      builder: (context, snap) {
        // ── Chargement ─────────────────────────────────────────────────────
        if (!snap.hasData) {
          return const SizedBox(
            height: 44,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.orangePrimary),
              ),
            ),
          );
        }

        final categories = snap.data!;
        if (categories.isEmpty) return const SizedBox(height: 44);

        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = categories[index];
              // Une puce est sélectionnée si on n'est pas en mode recherche
              // et que l'index correspond à la catégorie active.
              final selected = !searching && index == selectedIndex;

              return ChoiceChip(
                // Icône de la catégorie (reconstruite depuis le code point)
                avatar: Icon(
                  category.icon,
                  size: 18,
                  // Blanc si sélectionné, brun si non sélectionné
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
                label: Text(category.name),
                selected: selected,
                showCheckmark: false,

                // Couleurs selon l'état
                selectedColor: AppColors.orangePrimary, // fond orange si sélectionné
                backgroundColor: AppColors.cardCream,    // fond crème si non sélectionné

                // Texte : blanc si sélectionné, brun si non sélectionné
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textBrown,
                ),

                // Bordure : pas de noir. Fine bordure pêche si non sélectionné,
                // aucune bordure si sélectionné (le fond orange suffit).
                side: selected
                    ? BorderSide.none
                    : const BorderSide(color: AppColors.peachBorder, width: 1),

                // Forme arrondie (pilule)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),

                onSelected: (_) => onSelect(index),
              );
            },
          ),
        );
      },
    );
  }
}

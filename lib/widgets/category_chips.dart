import 'package:flutter/material.dart';
import '../models/app_user.dart'; // maybe not needed, but keep minimal
import '../models/dish.dart';
import '../models/client_info.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../data/menu_data.dart';
import '../widgets/dish_image.dart';

/// Widget affichant les puces de catégories sous forme de ChoiceChip.
/// Utilisé dans la page CartePage.
class CategoryChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool searching;

  const CategoryChips({
    Key? key,
    required this.selectedIndex,
    required this.onSelect,
    required this.searching,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: menuCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = menuCategories[index];
          final selected = !searching && index == selectedIndex;
          return ChoiceChip(
            avatar: Icon(
              category.icon,
              size: 18,
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
            ),
            label: Text(category.name),
            selected: selected,
            showCheckmark: false,
            selectedColor: colors.primary,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? colors.onPrimary : colors.onSurface,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            onSelected: (_) => onSelect(index),
          );
        },
      ),
    );
  }
}

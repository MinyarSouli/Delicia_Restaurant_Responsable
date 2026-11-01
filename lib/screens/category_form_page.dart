// lib/screens/category_form_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// Page de gestion des catégories (CRUD) pour le responsable.
//
// Fonctionnalités :
//  • Liste les catégories en temps réel (StreamBuilder → CategoryService)
//  • Bouton Ajouter → bottom sheet pour créer une catégorie
//  • Swipe left ou bouton modifier/supprimer sur chaque catégorie
//  • Sélection d'icône parmi une palette de 20 icônes Material
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/category.dart';
import '../services/category_service.dart';
import '../theme/app_colors.dart';

// ── Icônes disponibles pour les catégories ────────────────────────────────────
const List<IconData> _availableIcons = [
  Icons.lunch_dining,
  Icons.dinner_dining,
  Icons.coffee,
  Icons.local_drink,
  Icons.icecream,
  Icons.fastfood,
  Icons.ramen_dining,
  Icons.rice_bowl,
  Icons.set_meal,
  Icons.bakery_dining,
  Icons.cake,
  Icons.local_pizza,
  Icons.kebab_dining,
  Icons.soup_kitchen,
  Icons.local_bar,
  Icons.wine_bar,
  Icons.emoji_food_beverage,
  Icons.free_breakfast,
  Icons.brunch_dining,
  Icons.tapas,
];

/// Page principale de gestion des catégories.
class CategoryFormPage extends StatelessWidget {
  const CategoryFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Catégories',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textBrown,
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(context, null),
        backgroundColor: AppColors.orangePrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle catégorie'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.peachTop, AppColors.peachBottom],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<MenuCategory>>(
            stream: CategoryService.instance.watchCategories(),
            builder: (context, snap) {
              // ── États du Stream ──────────────────────────────────────────
              if (snap.hasError) {
                return Center(child: Text('Erreur : ${snap.error}'));
              }
              if (!snap.hasData) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.orangePrimary));
              }

              final categories = snap.data!;

              if (categories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.category_outlined,
                          size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text('Aucune catégorie',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Appuyez sur + pour en créer une',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  return _CategoryTile(
                    category: cat,
                    onEdit: () => _openSheet(context, cat),
                    onDelete: () => _confirmDelete(context, cat),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Ouvre le bottom sheet Ajouter / Modifier ─────────────────────────────
  void _openSheet(BuildContext context, MenuCategory? cat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategorySheet(category: cat),
    );
  }

  // ── Confirmation de suppression ───────────────────────────────────────────
  Future<void> _confirmDelete(BuildContext context, MenuCategory cat) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette catégorie ?'),
        content: Text(
            '« ${cat.name} » sera supprimée. Les plats de cette catégorie ne seront plus filtrés.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (ok == true) {
      await CategoryService.instance.delete(cat.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${cat.name} supprimée'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ));
    }
  }
}

// ── Tuile d'une catégorie dans la liste ──────────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final MenuCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A2216).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.orangePrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(category.icon,
              color: AppColors.orangePrimary, size: 24),
        ),
        title: Text(
          category.name,
          style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              color: AppColors.textBrown,
              fontSize: 16),
        ),
        subtitle: Text(
          'Ordre : ${category.order}',
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Bouton Modifier ────────────────────────────────────────
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: AppColors.orangePrimary),
              onPressed: onEdit,
              tooltip: 'Modifier',
            ),
            // ── Bouton Supprimer ───────────────────────────────────────
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error),
              onPressed: onDelete,
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet : Formulaire Ajouter / Modifier une catégorie ───────────────
class _CategorySheet extends StatefulWidget {
  final MenuCategory? category;

  const _CategorySheet({this.category});

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late int _selectedIconCode;
  bool _saving = false;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.category?.name ?? '');
    _selectedIconCode =
        widget.category?.iconCode ?? _availableIcons.first.codePoint;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      if (_isEdit) {
        // ── MODIFICATION ────────────────────────────────────────────────
        final updated = widget.category!.copyWith(
          name: _nameCtrl.text.trim(),
          iconCode: _selectedIconCode,
        );
        await CategoryService.instance.update(updated);
      } else {
        // ── AJOUT ───────────────────────────────────────────────────────
        final nextOrder = await CategoryService.instance.getNextOrder();
        final newCat = MenuCategory(
          id: '',
          name: _nameCtrl.text.trim(),
          iconCode: _selectedIconCode,
          order: nextOrder,
        );
        await CategoryService.instance.add(newCat);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.peachTop,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Titre du sheet ───────────────────────────────────────
              Text(
                _isEdit ? 'Modifier la catégorie' : 'Nouvelle catégorie',
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBrown),
              ),
              const SizedBox(height: 20),

              // ── Champ : Nom ──────────────────────────────────────────
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nom de la catégorie',
                  filled: true,
                  fillColor: AppColors.cardCream,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: AppColors.orangePrimary, width: 1.5)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nom obligatoire' : null,
              ),
              const SizedBox(height: 20),

              // ── Sélection d'icône ────────────────────────────────────
              Text(
                'Icône',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textBrown),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _availableIcons.map((icon) {
                  final selected = icon.codePoint == _selectedIconCode;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedIconCode = icon.codePoint),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.orangePrimary
                            : AppColors.cardCream,
                        borderRadius: BorderRadius.circular(12),
                        border: selected
                            ? null
                            : Border.all(
                                color: AppColors.peachBorder, width: 1),
                      ),
                      child: Icon(
                        icon,
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Bouton Enregistrer ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orangePrimary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_isEdit ? 'Enregistrer' : 'Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

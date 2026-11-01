// lib/screens/carte_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// Page Gestion du Menu (côté Admin) — CRUD complet connecté à Firebase.
//
// Architecture de la mise à jour en temps réel :
//   StreamBuilder<List<Dish>>
//     └─ DishService.instance.watchDishes()   ← Stream Firestore (onSnapshot)
//          └─ _col.orderBy('name').snapshots() ← écoute TOUTES les modifs
//
//   StreamBuilder<List<MenuCategory>>
//     └─ CategoryService.instance.watchCategories() ← categories en temps réel
//
// Quand l'admin ajoute / modifie / supprime un plat ou une catégorie dans
// Firestore, les StreamBuilders reçoivent automatiquement la nouvelle liste
// et reconstruisent l'interface — SANS rafraîchissement manuel.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/menu_data.dart' show menuDishes;
import '../models/category.dart';
import '../models/dish.dart';
import '../services/category_service.dart';
import '../services/dish_service.dart';
import '../theme/app_colors.dart';
import '../widgets/admin_dish_card.dart';
import '../widgets/category_chips.dart';
import 'category_form_page.dart';
import 'dish_form_page.dart';

/// Page menu côté admin : même design que le client + CRUD.
class CartePage extends StatefulWidget {
  const CartePage({super.key});

  @override
  State<CartePage> createState() => _CartePageState();
}

class _CartePageState extends State<CartePage> {
  // ── État local (recherche + filtre catégorie) ────────────────────────────
  final _searchController = TextEditingController();
  int _selectedCategory = 0;
  String _query = '';

  // ── dispose ────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // _filter() – Filtre la liste complète selon la recherche / catégorie
  // ─────────────────────────────────────────────────────────────────────────
  List<Dish> _filter(List<Dish> all, List<MenuCategory> categories) {
    final q = _query.trim().toLowerCase();

    // Si l'utilisateur a tapé quelque chose dans la barre de recherche
    if (q.isNotEmpty) {
      return all
          .where((d) =>
              d.name.toLowerCase().contains(q) ||
              d.description.toLowerCase().contains(q))
          .toList();
    }

    // Sinon, filtre par catégorie sélectionnée (si des catégories existent)
    if (categories.isEmpty) return all;
    final safeIndex = _selectedCategory.clamp(0, categories.length - 1);
    final category = categories[safeIndex].name;
    return all.where((d) => d.category == category).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Navigation vers le formulaire d'ajout / modification d'un plat
  // ─────────────────────────────────────────────────────────────────────────
  /// Ouvre [DishFormPage] en mode AJOUT (dish == null) ou MODIFICATION.
  void _openForm([Dish? dish]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DishFormPage(dish: dish)),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Navigation vers la page de gestion des catégories
  // ─────────────────────────────────────────────────────────────────────────
  void _openCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoryFormPage()),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // _confirmDelete() – Confirme puis supprime un plat dans Firestore
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _confirmDelete(Dish dish) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce plat ?'),
        content: Text('« ${dish.name} » sera supprimé définitivement.'),
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
      // ── SUPPRESSION FIREBASE ─────────────────────────────────────────────
      // DishService.delete() appelle _col.doc(id).delete() dans Firestore.
      // Le StreamBuilder de watchDishes() reçoit aussitôt la mise à jour
      // et retire la carte du plat de l'interface automatiquement.
      await DishService.instance.delete(dish.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${dish.name} supprimé'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // _seed() – Import initial du menu depuis menu_data.dart vers Firestore
  // ─────────────────────────────────────────────────────────────────────────
  /// Importe les plats de menu_data.dart dans Firestore SI la collection
  /// est vide. Bouton visible uniquement quand all.isEmpty.
  Future<void> _seed() async {
    // Importe aussi les catégories par défaut si nécessaire
    await CategoryService.instance.seedIfEmpty();
    final n = await DishService.instance.seedIfEmpty(menuDishes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(n == 0
          ? 'Le menu Firestore contient déjà des plats.'
          : '$n plats importés dans Firestore.'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // build() – Interface principale avec StreamBuilder imbriqué (temps réel)
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      // ── Bouton flottant : Ajouter un plat ─────────────────────────────────
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.extended(
          onPressed: () => _openForm(),
          backgroundColor: AppColors.orangePrimary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter un plat'),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.peachTop, AppColors.peachBottom],
          ),
        ),
        child: SafeArea(
          bottom: false,
          // ══════════════════════════════════════════════════════════════════
          // StreamBuilder des catégories : écoute "categories" en TEMPS RÉEL.
          // ══════════════════════════════════════════════════════════════════
          child: StreamBuilder<List<MenuCategory>>(
            stream: CategoryService.instance.watchCategories(),
            builder: (context, catSnap) {
              final categories = catSnap.data ?? [];

              // ════════════════════════════════════════════════════════════
              // StreamBuilder des plats : écoute "dishes" en TEMPS RÉEL.
              // ════════════════════════════════════════════════════════════
              return StreamBuilder<List<Dish>>(
                stream: DishService.instance.watchDishes(),
                builder: (context, snap) {
                  // ── États du Stream ────────────────────────────────────
                  if (snap.hasError) {
                    return Center(child: Text('Erreur : ${snap.error}'));
                  }
                  if (!snap.hasData) {
                    // Chargement initial : indicateur de progression
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.orangePrimary));
                  }

                  // snap.data! contient la liste complète et à jour
                  final all = snap.data!;
                  final dishes = _filter(all, categories); // applique recherche / catégorie

                  // Nom de la catégorie active pour le titre de section
                  final safeIndex =
                      _selectedCategory.clamp(0, categories.isEmpty ? 0 : categories.length - 1);
                  final activeCatName = categories.isEmpty
                      ? ''
                      : categories[safeIndex].name;

                  return CustomScrollView(
                    slivers: [
                      // ── En-tête : logo + bouton import ────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Délicia',
                                      style: GoogleFonts.pacifico(
                                          fontSize: 30,
                                          color: AppColors.orangePrimary,
                                          height: 1.1)),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.orangeDark,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('Admin',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const Spacer(),
                                  // ── Bouton Gérer les catégories ─────────
                                  IconButton(
                                    onPressed: _openCategories,
                                    icon: const Icon(Icons.category_rounded,
                                        color: AppColors.orangePrimary),
                                    tooltip: 'Gérer les catégories',
                                  ),
                                  // Bouton import visible uniquement si vide
                                  if (all.isEmpty)
                                    TextButton.icon(
                                      onPressed: _seed,
                                      icon: const Icon(
                                          Icons.cloud_upload_outlined),
                                      label: const Text('Importer le menu'),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // ── Barre de recherche ─────────────────────
                              TextField(
                                controller: _searchController,
                                onChanged: (v) =>
                                    setState(() => _query = v),
                                decoration: InputDecoration(
                                  hintText: 'Rechercher un plat...',
                                  prefixIcon: const Icon(Icons.search,
                                      color: AppColors.textSecondary),
                                  suffixIcon: searching
                                      ? IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _query = '');
                                          })
                                      : null,
                                  filled: true,
                                  fillColor: AppColors.cardCream,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: AppColors.orangePrimary,
                                          width: 1.5)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Filtres catégories ─────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: CategoryChips(
                            selectedIndex: safeIndex,
                            onSelect: (i) {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _selectedCategory = i;
                              });
                            },
                            searching: searching,
                          ),
                        ),
                      ),

                      // ── Titre de section + compteur ────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  searching
                                      ? 'Résultats de la recherche'
                                      : activeCatName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textBrown),
                                ),
                              ),
                              Text(
                                '${dishes.length} plat${dishes.length > 1 ? 's' : ''}',
                                style: textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Grille des plats (ou message "aucun plat") ─────
                      if (dishes.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off,
                                    size: 56,
                                    color: AppColors.textSecondary),
                                SizedBox(height: 12),
                                Text('Aucun plat trouvé',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          sliver: SliverGrid.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              mainAxisExtent: 300,
                            ),
                            itemCount: dishes.length,
                            itemBuilder: (context, i) {
                              final dish = dishes[i];
                              return AdminDishCard(
                                dish: dish,
                                onEdit: () => _openForm(dish),
                                onDelete: () => _confirmDelete(dish),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

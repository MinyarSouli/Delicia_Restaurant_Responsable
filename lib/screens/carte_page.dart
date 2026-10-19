import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/menu_data.dart';
import '../models/dish.dart';
import '../services/cart_service.dart';
import '../services/navigation_service.dart';
import '../widgets/dish_image.dart';
import 'dish_detail_page.dart';
import '../widgets/dish_card.dart';
import '../widgets/popular_dish_card.dart';
import '../widgets/cart_badge_button.dart';
import '../widgets/category_chips.dart';
import '../theme/app_colors.dart';

/// Page principale : consultation du menu par catégories.
class CartePage extends StatefulWidget {
  const CartePage({super.key});

  @override
  State<CartePage> createState() => _CartePageState();
}

class _CartePageState extends State<CartePage> {
  final _searchController = TextEditingController();
  int _selectedCategory = 0;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Plats à afficher : résultats de la recherche, sinon la catégorie choisie.
  List<Dish> get _visibleDishes {
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      return menuDishes
          .where(
            (d) =>
                d.name.toLowerCase().contains(q) ||
                d.description.toLowerCase().contains(q),
          )
          .toList();
    }
    final category = menuCategories[_selectedCategory].name;
    return menuDishes.where((d) => d.category == category).toList();
  }

  /// Liste des plats populaires (isPopular == true).
  List<Dish> get _popularDishes =>
      menuDishes.where((d) => d.isPopular).toList();

  /// Affiche un SnackBar flottant « <nom> ajouté au panier »
  /// avec le bouton d'action « Voir le panier ».
  void _showAdded(String dishName) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$dishName ajouté au panier',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90), // reste au-dessus du footer
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          action: SnackBarAction(
            label: 'Voir le panier',
            textColor: Colors.white,
            onPressed: () {
              // Bascule directement sur l'onglet Panier de MainShell
              NavigationService.instance.openCart();
            },
          ),
        ),
      );
  }

  /// Ouvre la page de détail du plat.
  /// Si le retour indique qu'un plat a été ajouté, affiche le SnackBar.
  Future<void> _openDetail(Dish dish) async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DishDetailPage(dish: dish)),
    );
    if (added == true && mounted) _showAdded(dish.name);
  }

  /// Ajoute le plat au panier directement (sans ouvrir le détail).
  void _quickAdd(Dish dish) {
    CartService.instance.add(dish);
    _showAdded(dish.name);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dishes = _visibleDishes;
    final searching = _query.trim().isNotEmpty;
    final popularDishes = _popularDishes;

    return Scaffold(
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
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // =========================================================
                  // EN-TÊTE : Logo "Délicia" + CartBadgeButton + Barre de recherche
                  // =========================================================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Délicia',
                                style: GoogleFonts.pacifico(
                                  fontSize: 30,
                                  color: AppColors.orangePrimary,
                                  height: 1.1,
                                ),
                              ),
                              const Spacer(),
                              CartBadgeButton(
                                onTap: () => NavigationService.instance.openCart(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ----- Barre de recherche -----
                          TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _query = value),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Rechercher un plat...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                              ),
                              suffixIcon: searching
                                  ? IconButton(
                                      tooltip: 'Effacer',
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _query = '');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: AppColors.cardCream,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.orangePrimary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // =========================================================
                  // BANNIÈRE "PLAT DU JOUR"
                  // =========================================================
                  if (!searching && popularDishes.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: _PlatDuJourBanner(
                          dish: popularDishes.first,
                          onTap: () => _openDetail(popularDishes.first),
                          onCommander: () => _quickAdd(popularDishes.first),
                        ),
                      ),
                    ),

                  // =========================================================
                  // PASTILLES DE CATÉGORIES
                  // =========================================================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: CategoryChips(
                        selectedIndex: _selectedCategory,
                        onSelect: (index) {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                            _selectedCategory = index;
                          });
                        },
                        searching: searching,
                      ),
                    ),
                  ),

                  // =========================================================
                  // SECTION POPULAIRES avec titre
                  // ListView horizontale avec padding vertical de 12 px et clipBehavior: Clip.none
                  // pour éviter de couper les ombres
                  // =========================================================
                  if (!searching && popularDishes.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                        child: Text(
                          'Populaires',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBrown,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 205, // Hauteur généreuse pour accueillir les ombres
                        child: ListView.builder(
                          clipBehavior: Clip.none, // Ne coupe pas l'ombre
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          itemCount: popularDishes.length,
                          itemBuilder: (context, index) {
                            final popular = popularDishes[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: PopularDishCard(
                                dish: popular,
                                onQuickAdd: () => _quickAdd(popular),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // =========================================================
                  // TITRE DE SECTION
                  // =========================================================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              searching
                                  ? 'Résultats de la recherche'
                                  : menuCategories[_selectedCategory].name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBrown,
                              ),
                            ),
                          ),
                          Text(
                            '${dishes.length} plat${dishes.length > 1 ? 's' : ''}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // =========================================================
                  // GRILLE DES PLATS
                  // SliverGridDelegateWithMaxCrossAxisExtent avec maxCrossAxisExtent: 220
                  // et mainAxisExtent: 300 pour garantir une hauteur fixe et zéro overflow !
                  // =========================================================
                  if (dishes.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 56,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucun plat trouvé',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                          mainAxisExtent: 300, // Hauteur FIXE : supprime tout overflow
                        ),
                        itemCount: dishes.length,
                        itemBuilder: (context, index) {
                          final dish = dishes[index];
                          return DishCard(
                            dish: dish,
                            onTap: () => _openDetail(dish),
                            onQuickAdd: () => _quickAdd(dish),
                          );
                        },
                      ),
                    ),
                ],
              ),

              // =========================================================
              // BARRE FLOTTANTE "Commander" (au-dessus du contenu)
              // =========================================================
              Positioned(
                left: 20,
                right: 20,
                bottom: 16,
                child: ListenableBuilder(
                  listenable: CartService.instance,
                  builder: (context, _) {
                    final cart = CartService.instance;
                    if (cart.itemCount == 0) return const SizedBox.shrink();

                    return Material(
                      color: colors.primary,
                      elevation: 8,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          NavigationService.instance.openCart();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: colors.onPrimary,
                                child: Text(
                                  '${cart.itemCount}',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Commander',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                formatPrice(cart.totalWithVat),
                                style: TextStyle(
                                  color: colors.onPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// WIDGET INTERNE : Bannière "Plat du jour"
// =====================================================================
class _PlatDuJourBanner extends StatelessWidget {
  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback onCommander;

  const _PlatDuJourBanner({
    required this.dish,
    required this.onTap,
    required this.onCommander,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3A2216).withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DishImage(path: dish.image),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.orangePrimary.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Plat du jour',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dish.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatPrice(dish.price),
                            style: textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFFFCB8E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onCommander,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orangePrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Commander',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

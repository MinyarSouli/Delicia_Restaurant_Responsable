import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/app_user.dart';
import '../models/client_info.dart';
import '../models/dish.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../widgets/dish_image.dart';
import '../widgets/table_number_dialog.dart';
import 'dish_detail_page.dart';
import 'login_page.dart';

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

  void _showAdded(String dishName) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$dishName ajouté au panier'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _openDetail(Dish dish) async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DishDetailPage(dish: dish)),
    );
    if (added == true && mounted) _showAdded(dish.name);
  }

  void _quickAdd(Dish dish) {
    CartService.instance.add(dish);
    _showAdded(dish.name);
  }

  // Parcours : connexion (si besoin) -> numéro de table.
  // Plus tard, cette fonction sera appelée depuis l'écran panier / addition.
  Future<void> _confirmOrder() async {
    AppUser? user = AuthService.instance.currentUser;

    user ??= await Navigator.push<AppUser>(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
    if (user == null || !mounted) return;

    final table = await showTableNumberDialog(context);
    if (table == null || !mounted) return;

    final info = CustomerInfo(fullName: user.name, tableNumber: table);
    debugPrint(info.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${info.fullName} - Table ${info.tableNumber} : informations validées',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dishes = _visibleDishes;
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ----- En-tête -----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.restaurant, color: colors.primary, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Bienvenue',
                          style: textTheme.titleSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Que souhaitez-vous\nmanger aujourd\'hui ?',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ----- Recherche -----
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un plat...',
                        prefixIcon: const Icon(Icons.search),
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
                        fillColor: colors.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ----- Catégories -----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: menuCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final category = menuCategories[index];
                      final selected = !searching && index == _selectedCategory;
                      return ChoiceChip(
                        avatar: Icon(
                          category.icon,
                          size: 18,
                          color: selected
                              ? colors.onPrimary
                              : colors.onSurfaceVariant,
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
                        onSelected: (_) {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                            _selectedCategory = index;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

            // ----- Titre de section -----
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
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${dishes.length} plat${dishes.length > 1 ? 's' : ''}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ----- Liste des plats -----
            if (dishes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 56,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      const Text('Aucun plat trouvé'),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: dishes.length,
                  itemBuilder: (context, index) {
                    final dish = dishes[index];
                    return _DishCard(
                      dish: dish,
                      onTap: () => _openDetail(dish),
                      onQuickAdd: () => _quickAdd(dish),
                    );
                  },
                ),
              ),
          ],
        ),
      ),

      // ----- Barre du panier (visible seulement s'il y a des articles) -----
      bottomNavigationBar: ListenableBuilder(
        listenable: CartService.instance,
        builder: (context, _) {
          final cart = CartService.instance;
          if (cart.itemCount == 0) return const SizedBox.shrink();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Material(
                color: colors.primary,
                elevation: 6,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _confirmOrder,
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
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          formatPrice(cart.total),
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
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Carte d'un plat : image, nom, description, prix et bouton "+".
class _DishCard extends StatelessWidget {
  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;

  const _DishCard({
    required this.dish,
    required this.onTap,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + bouton d'ajout rapide
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'dish-${dish.id}',
                    child: DishImage(path: dish.image),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Material(
                      color: colors.primary,
                      shape: const CircleBorder(),
                      elevation: 3,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onQuickAdd,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.add,
                            size: 20,
                            color: colors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Texte
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dish.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dish.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatPrice(dish.price),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

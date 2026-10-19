import 'package:flutter/material.dart';

import '../models/dish.dart';
import '../services/cart_service.dart';
import '../theme/app_colors.dart';
import '../widgets/dish_image.dart';

/// Détail d'un plat : image dans une grande carte crème avec marge,
/// bouton retour rond, nom, prix, suppléments en cartes sélectionnables,
/// et bouton du bas « Ajouter au panier • total » plein orange.
/// Retourne true à l'écran précédent si le plat a été ajouté au panier.
class DishDetailPage extends StatefulWidget {
  final Dish dish;

  const DishDetailPage({super.key, required this.dish});

  @override
  State<DishDetailPage> createState() => _DishDetailPageState();
}

class _DishDetailPageState extends State<DishDetailPage> {
  int _quantity = 1;
  final Set<int> _selected = {}; // indices des suppléments cochés

  double get _unitPrice {
    double extras = 0;
    for (final i in _selected) {
      extras += widget.dish.supplements[i].price;
    }
    return widget.dish.price + extras;
  }

  double get _total => _unitPrice * _quantity;

  void _addToCart() {
    final indices = _selected.toList()..sort();
    CartService.instance.add(
      widget.dish,
      quantity: _quantity,
      supplements: [for (final i in indices) widget.dish.supplements[i]],
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.peachTop, AppColors.peachBottom],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Barre d'en-tête avec bouton retour rond
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3A2216).withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textBrown,
                          size: 22,
                        ),
                        tooltip: 'Retour',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dish.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenu défilable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Grande carte crème avec image arrondie et marge
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.cardCream,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3A2216)
                                      .withValues(alpha: 0.12),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: AspectRatio(
                                aspectRatio: 16 / 11,
                                child: Hero(
                                  tag: 'dish-${dish.id}',
                                  child: DishImage(
                                    path: dish.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 2. Nom et Prix
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  dish.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBrown,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                formatPrice(dish.price),
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.orangePrimary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Catégorie
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardCream,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.peachBorder,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              dish.category,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textBrown,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Description
                          Text(
                            dish.description,
                            style: textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),

                          // 3. Suppléments en cartes sélectionnables
                          if (dish.supplements.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Personnalisez votre commande',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBrown,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Suppléments (facultatif)',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (var i = 0; i < dish.supplements.length; i++)
                              _SupplementTile(
                                supplement: dish.supplements[i],
                                selected: _selected.contains(i),
                                onChanged: (checked) => setState(() {
                                  if (checked) {
                                    _selected.add(i);
                                  } else {
                                    _selected.remove(i);
                                  }
                                }),
                              ),
                          ],

                          // 4. Quantité
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardCream,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3A2216)
                                      .withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Quantité',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBrown,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.peachTop,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.peachBorder,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'Diminuer',
                                        icon: const Icon(
                                          Icons.remove,
                                          size: 18,
                                          color: AppColors.textBrown,
                                        ),
                                        onPressed: _quantity > 1
                                            ? () => setState(() => _quantity--)
                                            : null,
                                      ),
                                      SizedBox(
                                        width: 32,
                                        child: Text(
                                          '$_quantity',
                                          textAlign: TextAlign.center,
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textBrown,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Augmenter',
                                        icon: const Icon(
                                          Icons.add,
                                          size: 18,
                                          color: AppColors.orangePrimary,
                                        ),
                                        onPressed: _quantity < 20
                                            ? () => setState(() => _quantity++)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Barre du bas : bouton plein orange « Ajouter au panier • total »
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardCream,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3A2216).withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: SafeArea(
          top: false,
          child: FilledButton(
            onPressed: _addToCart,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: AppColors.orangePrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                const SizedBox(width: 10),
                const Text(
                  'Ajouter au panier',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•  ${formatPrice(_total)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte de supplément personnalisée, sans aucun contour noir.
class _SupplementTile extends StatelessWidget {
  final Supplement supplement;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _SupplementTile({
    required this.supplement,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = supplement.price == 0
        ? 'Gratuit'
        : '+ ${formatPrice(supplement.price)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.peachTop.withValues(alpha: 0.7)
            : AppColors.cardCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.orangePrimary : AppColors.peachBorder,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A2216).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: selected,
        onChanged: (value) => onChanged(value ?? false),
        activeColor: AppColors.orangePrimary,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          supplement.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textBrown,
          ),
        ),
        subtitle: Text(
          priceText,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

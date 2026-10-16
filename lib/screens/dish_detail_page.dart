import 'package:flutter/material.dart';

import '../models/dish.dart';
import '../services/cart_service.dart';
import '../widgets/dish_image.dart';

/// Détail d'un plat : image, description, prix, suppléments et quantité.
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ----- Grande image avec bouton retour -----
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: colors.surface,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: colors.surface,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.onSurface),
                  tooltip: 'Retour',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'dish-${dish.id}',
                child: DishImage(path: dish.image),
              ),
            ),
          ),

          // ----- Contenu -----
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              dish.name,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formatPrice(dish.price),
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(dish.category),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                        backgroundColor: colors.secondaryContainer,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dish.description,
                        style: textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      // ----- Suppléments -----
                      if (dish.supplements.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Text(
                          'Personnalisez votre commande',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Suppléments (facultatif)',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
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

                      // ----- Quantité -----
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            'Quantité',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  tooltip: 'Diminuer',
                                  icon: const Icon(Icons.remove),
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
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Augmenter',
                                  icon: const Icon(Icons.add),
                                  onPressed: _quantity < 20
                                      ? () => setState(() => _quantity++)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ----- Barre du bas : bouton d'ajout avec le total -----
      bottomNavigationBar: Material(
        elevation: 8,
        color: colors.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: FilledButton(
              onPressed: _addToCart,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined),
                  const SizedBox(width: 10),
                  const Text(
                    'Ajouter au panier',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '•  ${formatPrice(_total)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Une ligne de supplément avec case à cocher et prix.
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
    final colors = Theme.of(context).colorScheme;
    final priceText = supplement.price == 0
        ? 'Gratuit'
        : '+ ${formatPrice(supplement.price)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected ? colors.primaryContainer.withValues(alpha: 0.4) : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: selected,
        onChanged: (value) => onChanged(value ?? false),
        controlAffinity: ListTileControlAffinity.trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          supplement.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(priceText),
      ),
    );
  }
}

// lib/screens/cart_page.dart
import 'package:flutter/material.dart';

import '../models/dish.dart';        // Fournit Supplement et formatPrice
import '../services/cart_service.dart';
import '../services/navigation_service.dart';
import '../widgets/dish_image.dart';
import '../services/checkout_flow.dart';
import '../config/app_config.dart';
import '../models/cart_item.dart';
import '../theme/app_colors.dart';

// =====================================================================
// PAGE PANIER
// Affiche la liste des articles et l'addition.
// isTab : si true, la page est affichée comme onglet dans MainShell,
// donc sans bouton retour dans l'AppBar.
// =====================================================================
class CartPage extends StatelessWidget {
  final bool isTab;

  const CartPage({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder se reconstruit automatiquement quand le panier change.
    return ListenableBuilder(
      listenable: CartService.instance,
      builder: (context, _) {
        final cart = CartService.instance;
        final items = cart.items;

        // ----- État vide -----
        if (items.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Mon panier (0)'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: !isTab, // Pas de retour si c'est un onglet
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
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Votre panier est vide',
                      style: TextStyle(
                        color: AppColors.textBrown,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('Voir le menu'),
                      onPressed: () {
                        if (isTab) {
                          NavigationService.instance.openMenu();
                        } else {
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.orangePrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ----- État avec articles -----
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Mon panier (${cart.itemCount})',
              style: const TextStyle(
                color: AppColors.textBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: !isTab, // Pas de retour si c'est un onglet
            iconTheme: const IconThemeData(color: AppColors.textBrown),
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
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _CartItemCard(item: item, isTab: isTab);
              },
            ),
          ),
          bottomNavigationBar: _CartSummarySection(isTab: isTab),
        );
      },
    );
  }
}

// =====================================================================
// CARTE D'UN ARTICLE DU PANIER
// Carte crème, rayon 20, ombre douce.
// Glissement vers la gauche = supprimer avec annulation.
// =====================================================================
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final bool isTab;

  const _CartItemCard({required this.item, required this.isTab});

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey(item.key),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        cart.remove(item);
        // SnackBar de suppression : marge suffisante au-dessus du footer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.dish.name} retiré',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            action: SnackBarAction(
              label: 'Annuler',
              textColor: Colors.white,
              onPressed: () => cart.restore(item),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardCream,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3A2216).withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image ronde 72 px
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: DishImage(path: item.dish.image, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(width: 12),

              // Nom, suppléments, prix
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.dish.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBrown,
                      ),
                    ),
                    if (item.supplements.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.supplements.map((s) => s.name).join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),

                    // Ligne prix : "14.000 DT × 2" et le prix de ligne à droite en orange
                    Row(
                      children: [
                        Text(
                          '${formatPrice(item.dish.price)} × ${item.quantity}',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatPrice(item.total),
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.orangePrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _QuantitySelector(item: item),
                        const Spacer(),
                        if (item.dish.supplements.isNotEmpty)
                          TextButton(
                            onPressed: () =>
                                _showSupplementEditor(context, item),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: const Size(48, 36),
                              foregroundColor: AppColors.orangePrimary,
                            ),
                            child: const Text(
                              'Modifier',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
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

  void _showSupplementEditor(BuildContext context, CartItem item) async {
    final dish = item.dish;
    final Set<Supplement> selected = Set<Supplement>.from(item.supplements);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.peachBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choisissez les suppléments',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textBrown,
                ),
              ),
              const SizedBox(height: 8),
              ...dish.supplements.map((supp) {
                final isSelected = selected.contains(supp);
                return StatefulBuilder(
                  builder: (context, setStateLocal) {
                    return CheckboxListTile(
                      title: Text(supp.name),
                      subtitle: Text(formatPrice(supp.price)),
                      value: isSelected,
                      activeColor: AppColors.orangePrimary,
                      onChanged: (v) {
                        setStateLocal(() {
                          if (v == true) {
                            selected.add(supp);
                          } else {
                            selected.remove(supp);
                          }
                        });
                      },
                    );
                  },
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    CartService.instance.replaceSupplements(
                      item,
                      selected.toList(),
                    );
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: AppColors.orangePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =====================================================================
// SÉLECTEUR DE QUANTITÉ HORIZONTAL EN PILULE
// =====================================================================
class _QuantitySelector extends StatelessWidget {
  final CartItem item;
  const _QuantitySelector({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.peachTop,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.peachBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => cart.decrease(item),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.cardCream,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.remove,
                size: 16,
                color: AppColors.textBrown,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textBrown,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => cart.increase(item),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.orangePrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// BLOC ADDITION
// =====================================================================
class _CartSummarySection extends StatelessWidget {
  final bool isTab;

  const _CartSummarySection({this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    final subtotal = cart.subtotal;
    final vatAmount = subtotal * vatRate;
    final total = subtotal + vatAmount;

    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A3A2216),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow(
              label: 'Sous-total HT',
              value: formatPrice(subtotal),
              textTheme: textTheme,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'TVA (${(vatRate * 100).toStringAsFixed(0)} %)',
              value: formatPrice(vatAmount),
              textTheme: textTheme,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: AppColors.peachBorder, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total TTC',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBrown,
                  ),
                ),
                Text(
                  formatPrice(total),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.orangePrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final info = await identifyCustomer(context);
                  if (info != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Commande confirmée'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: AppColors.orangePrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(
                  'Confirmer la commande · ${formatPrice(total)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {
                if (isTab) {
                  NavigationService.instance.openMenu();
                } else {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }
              },
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('Ajouter un plat'),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textBrown),
        ),
      ],
    );
  }
}

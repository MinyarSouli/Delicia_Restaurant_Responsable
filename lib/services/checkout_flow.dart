// lib/services/checkout_flow.dart
// ─────────────────────────────────────────────────────────────────────────────
// Flux de validation de commande — identification du client.
//
// identifyCustomer(context) affiche une boîte de dialogue demandant
// le numéro de table ou le nom du client, puis renvoie les informations
// saisies sous forme de [CustomerInfo].
//
// Retourne null si l'utilisateur annule.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/table_number_dialog.dart';

/// Informations d'identification du client lors du passage de commande.
class CustomerInfo {
  final String tableOrName;

  const CustomerInfo({required this.tableOrName});
}

/// Affiche la boîte de dialogue d'identification et retourne [CustomerInfo]
/// ou null si l'utilisateur annule.
Future<CustomerInfo?> identifyCustomer(BuildContext context) async {
  // Affiche le dialogue de saisie du numéro de table (retourne int? ou null)
  final tableNumber = await showTableNumberDialog(context);

  if (tableNumber == null) return null;

  return CustomerInfo(tableOrName: 'Table $tableNumber');
}

/// Widget de dialogue de confirmation de commande (affiché après identifyCustomer).
/// Peut être utilisé pour afficher un récapitulatif avant envoi final.
class OrderConfirmationDialog extends StatelessWidget {
  final CustomerInfo info;
  final double total;

  const OrderConfirmationDialog({
    super.key,
    required this.info,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.cardCream,
      title: const Text(
        'Confirmer la commande',
        style: TextStyle(
          color: AppColors.textBrown,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Table / Nom : ${info.tableOrName}',
            style: const TextStyle(color: AppColors.textBrown),
          ),
          const SizedBox(height: 8),
          Text(
            'Total : ${total.toStringAsFixed(3)} DT',
            style: const TextStyle(
              color: AppColors.orangePrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.orangePrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Commander'),
        ),
      ],
    );
  }
}

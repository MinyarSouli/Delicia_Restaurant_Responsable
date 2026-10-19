// lib/services/checkout_flow.dart
import 'package:flutter/material.dart';

import '../models/client_info.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../widgets/table_number_dialog.dart';
import '../screens/login_page.dart';

/// Identifie le client avant la confirmation de la commande.
/// Reprend exactement la logique de l'ancienne `_confirmOrder` de `CartePage`.
/// Retourne un [CustomerInfo] si l'utilisateur a fourni son nom et le numéro de table,
/// sinon retourne `null`.
Future<CustomerInfo?> identifyCustomer(BuildContext context) async {
  // Vérifier si l'utilisateur est déjà connecté.
  AppUser? user = AuthService.instance.currentUser;

  // Si aucun utilisateur connecté, ouvrir la page de connexion/register.
  if (user == null) {
    user = await Navigator.push<AppUser>(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
    if (user == null) return null; // L'utilisateur a abandonné la connexion.
  }

  // Demander le numéro de table.
  final int? table = await showTableNumberDialog(context);
  if (table == null) return null; // Abandon du dialogue.

  // Créer les informations du client.
  final info = CustomerInfo(fullName: user.name, tableNumber: table);

  // Afficher un SnackBar de confirmation rapide.
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${info.fullName} - Table ${info.tableNumber} : informations validées',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  return info;
}

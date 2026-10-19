import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Affiche une boîte de dialogue pour saisir le numéro de table.
/// Retourne le numéro (int) ou null si le client annule.
///
/// Utilisation :
///   final table = await showTableNumberDialog(context);
Future<int?> showTableNumberDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    barrierDismissible: false, // le client doit valider ou annuler
    builder: (_) => const _TableNumberDialog(),
  );
}

class _TableNumberDialog extends StatefulWidget {
  const _TableNumberDialog();

  @override
  State<_TableNumberDialog> createState() => _TableNumberDialogState();
}

class _TableNumberDialogState extends State<_TableNumberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    // Vérifie la validation avant de fermer
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, int.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Rayon 28 pour des coins très arrondis
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: AppColors.cardCream, // fond crème

      // Icône table dans un cercle orange pastel
      icon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          // Cercle orange très doux
          color: AppColors.orangePrimary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.table_restaurant,
          size: 32,
          color: AppColors.orangePrimary,
        ),
      ),

      title: const Text(
        'Numéro de table',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textBrown,
        ),
      ),

      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Texte d'explication en gris-brun
            Text(
              'Indiquez le numéro inscrit sur votre table pour que nous puissions vous servir.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            // ----- Champ numéro de table -----
            // Fond crème légèrement plus clair, bordure pêche, rayon 16
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 3,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onFieldSubmitted: (_) => _submit(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: AppColors.textBrown,
              ),
              decoration: InputDecoration(
                hintText: '0',
                counterText: '', // cache le compteur « 0/3 »
                filled: true,
                fillColor: const Color(0xFFFFF9F2), // légèrement plus clair
                // Bordure pêche au repos
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.peachBorder,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.peachBorder,
                    width: 1,
                  ),
                ),
                // Bordure orange au focus
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.orangePrimary,
                    width: 2,
                  ),
                ),
                // Bordure rouge sur erreur
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
              ),
              // Validation inchangée
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez saisir le numéro de table';
                }
                final n = int.tryParse(value.trim());
                if (n == null || n <= 0) return 'Numéro de table invalide';
                return null;
              },
            ),
          ],
        ),
      ),

      // Boutons en bas : Annuler à gauche, Valider à droite
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        // Bouton Annuler
        TextButton(
          onPressed: () => Navigator.pop(context), // retourne null
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            minimumSize: const Size(80, 48),
          ),
          child: const Text('Annuler'),
        ),

        // Bouton Valider : plein orange, rayon 14
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Valider'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.orangePrimary,
            minimumSize: const Size(100, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

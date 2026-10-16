import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, int.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: CircleAvatar(
        radius: 30,
        backgroundColor: colors.primaryContainer,
        child: Icon(
          Icons.table_restaurant,
          size: 32,
          color: colors.onPrimaryContainer,
        ),
      ),
      title: const Text('Numéro de table'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Indiquez le numéro inscrit sur votre table pour que nous puissions vous servir.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
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
              ),
              decoration: InputDecoration(
                hintText: '0',
                counterText: '', // cache le compteur "0/3"
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.primary, width: 2),
                ),
              ),
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
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // retourne null
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check),
          label: const Text('Valider'),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

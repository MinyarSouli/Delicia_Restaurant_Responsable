import 'package:flutter/material.dart';

/// En-tête commun aux pages Login et Register :
/// un bandeau coloré avec un logo, un titre et un sous-titre.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBack;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, top + 12, 24, 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.tertiary],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        children: [
          // Bouton retour (facultatif)
          SizedBox(
            height: 48,
            child: Align(
              alignment: Alignment.centerLeft,
              child: showBack
                  ? IconButton(
                      icon: Icon(Icons.arrow_back, color: colors.onPrimary),
                      tooltip: 'Retour',
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
            ),
          ),
          // Logo
          CircleAvatar(
            radius: 36,
            backgroundColor: colors.onPrimary,
            child: Icon(Icons.restaurant, size: 38, color: colors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.onPrimary.withValues(alpha: 230)),
          ),
        ],
      ),
    );
  }
}

/// Style commun des champs de saisie : fond doux, coins arrondis,
/// bordure colorée au focus.
InputDecoration authDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
  String? hint,
  Widget? suffix,
}) {
  final colors = Theme.of(context).colorScheme;
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon),
    suffixIcon: suffix,
    filled: true,
    fillColor: colors.surfaceContainerHighest,
    border: border(Colors.transparent),
    enabledBorder: border(Colors.transparent),
    focusedBorder: border(colors.primary, 2),
    errorBorder: border(colors.error),
    focusedErrorBorder: border(colors.error, 2),
  );
}

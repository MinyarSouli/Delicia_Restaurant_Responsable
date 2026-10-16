import 'package:flutter/material.dart';

/// Affiche l'image d'un plat.
/// - Si [path] commence par "http" : image depuis internet.
/// - Sinon : image locale (asset), ex. assets/images/burger.jpg
/// Pendant le chargement ou en cas d'erreur, un joli remplacement s'affiche.
class DishImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const DishImage({super.key, required this.path, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Affiché si l'image ne charge pas
    final fallback = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.tertiaryContainer],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 40,
          color: colors.onPrimaryContainer.withValues(alpha: 0.6),
        ),
      ),
    );

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: colors.surfaceContainerHighest,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return Image.asset(
      path,
      fit: fit,
      width: double.infinity,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Affiche l'image d'un plat.
/// - Si [path] commence par "http" : image depuis internet.
/// - Sinon : image locale (asset), ex. assets/images/burger.jpg
/// Pendant le chargement : fond pêche avec indicateur orange.
/// En cas d'erreur : fallback chaleureux pêche/orange.
class DishImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const DishImage({super.key, required this.path, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    // Fond affiché si l'image est introuvable ou en erreur
    final fallback = Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.peachTop, AppColors.peachBottom],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 36,
          color: AppColors.orangePrimary.withValues(alpha: 0.5),
        ),
      ),
    );

    // Image réseau (URL internet)
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          // Fond pêche chaleureux pendant le chargement
          return Container(
            color: AppColors.peachTop,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orangePrimary),
                ),
              ),
            ),
          );
        },
        errorBuilder: (_, err, stack) => fallback,
      );
    }

    // Image locale (Asset)
    return Image.asset(
      path,
      fit: fit,
      width: double.infinity,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

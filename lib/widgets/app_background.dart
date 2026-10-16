// lib/widgets/app_background.dart
// Widget affichant un dégradé vertical pêche derrière son enfant.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
  });

  /// Le widget enfant affiché au-dessus du dégradé.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.peachTop,
            AppColors.peachBottom,
          ],
        ),
      ),
      child: child,
    );
  }
}

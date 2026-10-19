import 'package:flutter/foundation.dart';

/// Service simple permettant de contrôler l'onglet actif dans MainShell
/// depuis n'importe où dans l'application (ex : bouton panier, barre Commander, etc.).
class NavigationService {
  NavigationService._();
  static final NavigationService instance = NavigationService._();

  /// Index de l'onglet actuellement sélectionné dans MainShell :
  /// 0 = Carte / Menu
  /// 1 = Panier
  /// 2 = Commandes
  /// 3 = Profil
  final ValueNotifier<int> currentTab = ValueNotifier<int>(0);

  /// Méthode utilitaire pour basculer vers un onglet spécifique
  void switchToTab(int index) {
    currentTab.value = index;
  }

  /// Raccourci pour aller directement au panier
  void openCart() {
    currentTab.value = 1;
  }

  /// Raccourci pour revenir au menu
  void openMenu() {
    currentTab.value = 0;
  }
}

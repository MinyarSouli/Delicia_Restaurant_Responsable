import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';
import 'carte_page.dart';
import 'cart_page.dart';
import 'login_page.dart';
import 'register_page.dart';

/// Écran principal avec barre de navigation inférieure (footer).
/// Utilise un IndexedStack pour conserver l'état de chaque onglet.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    // Écoute les demandes de changement d'onglet (ex : depuis le panier ou la barre Commander)
    NavigationService.instance.currentTab.addListener(_onTabServiceChange);
  }

  @override
  void dispose() {
    NavigationService.instance.currentTab.removeListener(_onTabServiceChange);
    super.dispose();
  }

  void _onTabServiceChange() {
    if (mounted) {
      // Nettoie immédiatement les SnackBars lors du changement d'onglet
      ScaffoldMessenger.of(context).clearSnackBars();
      setState(() {});
    }
  }

  void _onTabSelected(int index) {
    if (NavigationService.instance.currentTab.value != index) {
      ScaffoldMessenger.of(context).clearSnackBars();
      NavigationService.instance.switchToTab(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = NavigationService.instance.currentTab.value;

    return Scaffold(
      body: IndexedStack(
        index: activeIndex,
        children: const [
          CartePage(),           // 0 = Menu / Carte
          CartPage(isTab: true), // 1 = Panier en onglet (pas de flèche retour)
          _OrdersTab(),          // 2 = Commandes
          _ProfileTab(),         // 3 = Profil
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.orangeDark, // Orange foncé #A44519
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3A2216).withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListenableBuilder(
              listenable: CartService.instance,
              builder: (context, _) {
                final cartCount = CartService.instance.itemCount;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavBarItem(
                      index: 0,
                      icon: Icons.restaurant_menu_rounded,
                      label: 'Menu',
                      isSelected: activeIndex == 0,
                      onTap: () => _onTabSelected(0),
                    ),
                    _NavBarItem(
                      index: 1,
                      icon: Icons.shopping_bag_outlined,
                      label: 'Panier',
                      isSelected: activeIndex == 1,
                      badgeCount: cartCount,
                      onTap: () => _onTabSelected(1),
                    ),
                    _NavBarItem(
                      index: 2,
                      icon: Icons.receipt_long_rounded,
                      label: 'Commandes',
                      isSelected: activeIndex == 2,
                      onTap: () => _onTabSelected(2),
                    ),
                    _NavBarItem(
                      index: 3,
                      icon: Icons.person_outline_rounded,
                      label: 'Profil',
                      isSelected: activeIndex == 3,
                      onTap: () => _onTabSelected(3),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Élément individuel de la barre de navigation
class _NavBarItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cercle orange clair derrière l'icône quand sélectionné
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.peachTop.withValues(alpha: 0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -2,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$badgeCount',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Onglet 2 : Commandes (Écran simple remplissant tout l'écran)
class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.peachTop, AppColors.peachBottom],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'Mes commandes',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBrown,
                ),
              ),
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3A2216).withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 44,
                  color: AppColors.orangePrimary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Vos commandes apparaîtront ici',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBrown,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dès que vous validez une commande au restaurant, vous pourrez suivre son état ici en temps réel.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Onglet 3 : Profil (remplit tout l'écran sans cassure)
class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.peachTop, AppColors.peachBottom],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'Mon Profil',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBrown,
                ),
              ),
              const SizedBox(height: 32),

              // Carte profil
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3A2216).withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: user != null
                    // Utilisateur connecté
                    ? Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: AppColors.orangePrimary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                // On capture le messenger AVANT le await
                                // (bonne pratique Flutter : ne pas utiliser context après un appel async)
                                final messenger = ScaffoldMessenger.of(context);
                                await AuthService.instance.logout();
                                if (!mounted) return;
                                setState(() {});
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: const Text('Déconnexion réussie'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.logout_rounded,
                                  color: AppColors.error),
                              label: const Text(
                                'Se déconnecter',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.error, width: 1.2),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    // Utilisateur non connecté
                    : Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: AppColors.peachTop,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              size: 40,
                              color: AppColors.orangePrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bienvenue chez Délicia',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBrown,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Connectez-vous pour retrouver vos commandes et profiter d\'un suivi personnalisé.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () async {
                                final res = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                                if (res != null) {
                                  setState(() {});
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.orangePrimary,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Se connecter'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () async {
                                final res = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                                if (res != null) {
                                  setState(() {});
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.orangePrimary,
                                side: const BorderSide(
                                    color: AppColors.orangePrimary, width: 1.5),
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Créer un compte'),
                            ),
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
}

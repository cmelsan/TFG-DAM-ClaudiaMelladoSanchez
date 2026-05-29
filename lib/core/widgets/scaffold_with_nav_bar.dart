import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/widgets/app_fab.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/chat/presentation/screens/chat_screen.dart';

/// Shell persistente con barra de navegación personalizada.
/// En web el chatbot se muestra como panel flotante; en móvil navega a /chat.
class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  bool _chatOpen = false;

  void _toggleChat() => setState(() => _chatOpen = !_chatOpen);
  void _closeChat() => setState(() => _chatOpen = false);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        body: Stack(
          children: [
            widget.navigationShell,
            if (_chatOpen)
              _ChatOverlayPanel(onClose: _closeChat),
            Positioned(
              right: 20,
              bottom: 20,
              child: AppFab(
                isOpen: _chatOpen,
                onPressed: _toggleChat,
              ),
            ),
          ],
        ),
      );
    }

    // ── Móvil: navegación a ruta /chat (pantalla completa) ────────────────
    final cartCount = ref.watch(cartItemsCountProvider);

    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      body: widget.navigationShell,
      floatingActionButton: AppFab(
        onPressed: () => context.push('/chat'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _ModernNavBar(
        selectedIndex: widget.navigationShell.currentIndex,
        cartCount: cartCount,
        onTap: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation:
              index == widget.navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ── Panel flotante del chatbot (web) ─────────────────────────────────────────

class _ChatOverlayPanel extends StatelessWidget {
  const _ChatOverlayPanel({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final panelH = (screenH - 100).clamp(400.0, 600.0);

    return Positioned(
      right: 20,
      bottom: 80,
      width: 380,
      height: panelH,
      child: Material(
        elevation: 20,
        shadowColor: Colors.black38,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ChatScreen(onClose: onClose),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
          duration: 200.ms,
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomRight,
        )
        .fadeIn(duration: 150.ms);
  }
}

// ── Barra de navegación personalizada ────────────────────────────────────────

class _ModernNavBar extends StatelessWidget {
  const _ModernNavBar({
    required this.selectedIndex,
    required this.cartCount,
    required this.onTap,
  });

  final int selectedIndex;
  final int cartCount;
  final ValueChanged<int> onTap;

  static const _navItems = [
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Inicio',
    ),
    _NavItemData(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Menú',
    ),
    _NavItemData(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: 'Carrito',
    ),
    _NavItemData(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 28,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              for (int i = 0; i < _navItems.length; i++)
                Expanded(
                  child: _NavItem(
                    data: _navItems[i],
                    selected: selectedIndex == i,
                    badge: i == 2 ? cartCount : 0,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Datos de cada pestaña ─────────────────────────────────────────────────────

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ── Widget de cada pestaña ────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final _NavItemData data;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? AppTokens.brandPrimary : const Color(0xFFAAAAAA);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono con badge opcional
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    selected ? data.activeIcon : data.icon,
                    key: ValueKey(selected),
                    color: color,
                    size: 25,
                  ),
                ),
                if (badge > 0)
                  Positioned(
                    top: -5,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTokens.danger,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 0.1,
              ),
              child: Text(data.label),
            ),
            const SizedBox(height: 4),
            // Punto indicador animado
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              width: selected ? 5 : 0,
              height: selected ? 5 : 0,
              decoration: const BoxDecoration(
                color: AppTokens.brandPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

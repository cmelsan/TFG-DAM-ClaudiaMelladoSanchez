import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:sabor_de_casa/core/widgets/web_footer.dart';
import 'package:sabor_de_casa/core/widgets/web_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/location_section.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sabor_de_casa/features/cart/domain/models/cart_item.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/home/presentation/providers/subscription_provider.dart';
import 'package:sabor_de_casa/features/menu/domain/models/daily_special.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/daily_special_notifier.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/menu_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/screens/dish_detail_screen.dart';

class HomeScreenWeb extends ConsumerStatefulWidget {
  const HomeScreenWeb({super.key});

  @override
  ConsumerState<HomeScreenWeb> createState() => _HomeScreenWebState();
}

class _HomeScreenWebState extends ConsumerState<HomeScreenWeb> {
  late final ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        final scrolled = _scrollController.offset > 10;
        if (scrolled != _isScrolled) {
          setState(() => _isScrolled = scrolled);
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const _WebCartDrawer(),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80), // offset navbar fija
                _WebHero(),
            const _WebDailyMenuSection(),
            const _WebCateringBanner(),
            const _WebTopDishesCarousel(),
            const _WebSaborBanner(),
            const _WebOffersSection(),
            const _WebEncargosBanner(),
            const _WebHowItWorksSection(),
            const _WebTestimonialsSection(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 56),
                      _WebSeasonalSection(),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
            const _WebSubscriptionSection(),
            const LocationSection(),
            const WebFooter(),
          ],
        ),
          ),
          // Navbar fija superpuesta
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: WebNavbar(
              isScrolled: _isScrolled,
              activeRoute: RouteNames.home,
              onCartTap: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Navbar Web (privado, conservado) ── use WebNavbar from core/widgets ─────

class _WebNavbar extends ConsumerWidget {
  const _WebNavbar({required this.isScrolled});

  final bool isScrolled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final cartCount = ref.watch(cartItemsCountProvider);
    final profile = authState.valueOrNull;
    final screenW = MediaQuery.sizeOf(context).width;
    final navHPad = screenW < 500 ? 16.0 : 40.0;
    final navH = screenW < 500 ? 72.0 : 120.0;
    final logoFontSize = screenW < 500 ? 22.0 : 32.0;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isScrolled
                ? Colors.white.withValues(alpha: 0.82)
                : Colors.white,
            border: const Border(
              top: BorderSide(color: AppTokens.brandPrimary, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isScrolled ? 0.12 : 0.07,
                ),
                blurRadius: isScrolled ? 24 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: navHPad),
          child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: SizedBox(
            height: navH,
            child: Row(
              children: [
                // Logo
                Flexible(
                  child: GestureDetector(
                    onTap: () => context.goNamed(RouteNames.home),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sabor de Casa',
                            style: GoogleFonts.syne(
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              fontSize: logoFontSize,
                              letterSpacing: 0,
                              height: 1,
                              color: AppTokens.brandPrimary,
                            ),
                          ),
                        ),
                        if (screenW >= 400) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Sanlúcar de Barrameda',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                              color: const Color(0xFF888888),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Nav links - hidden on narrow screens
                if (MediaQuery.sizeOf(context).width >= 700) ...[
                  _NavLink(
                    label: 'Menú',
                    onTap: () => context.goNamed(RouteNames.menu),
                  ),
                  const SizedBox(width: 8),
                  _NavLink(
                    label: 'Catering',
                    onTap: () => context.goNamed(RouteNames.catering),
                  ),
                  const SizedBox(width: 8),
                  _NavLink(
                    label: 'Contacto',
                    onTap: () => context.goNamed(RouteNames.contact),
                  ),
                  const SizedBox(width: 24),
                ],

                // Carrito
                IconButton(
                  iconSize: 26,
                  icon: Badge.count(
                    count: cartCount,
                    isLabelVisible: cartCount > 0,
                    backgroundColor: Colors.red,
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF333333),
                      size: 26,
                    ),
                  ),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),

                const SizedBox(width: 8),

                // Auth
                if (profile == null && MediaQuery.sizeOf(context).width >= 700) ...[
                  OutlinedButton(
                    onPressed: () => context.goNamed(RouteNames.login),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTokens.brandPrimary,
                      side: const BorderSide(color: AppTokens.brandPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      textStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Iniciar sesión'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => context.goNamed(RouteNames.register),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTokens.brandPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      textStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Registrarse'),
                  ),
                ] else if (profile != null)
                  GestureDetector(
                    onTap: () => context.goNamed(RouteNames.profile),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTokens.brandPrimary.withValues(
                            alpha: 0.15,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppTokens.brandPrimary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          profile.fullName?.split(' ').first ??
                              profile.email.split('@').first,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Color(0xFF111111),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: _hovered
                      ? AppTokens.brandPrimary
                      : const Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 2.5,
                width: _hovered ? 24 : 0,
                decoration: BoxDecoration(
                  color: AppTokens.brandPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Hero Web â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _WebHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final heroH = screenW < 480 ? 340.0 : screenW < 768 ? 480.0 : 600.0;
    final heroFont = screenW < 768 ? 40.0 : 58.0;
    final isMobile = screenW < 768;
    return SizedBox(
      height: heroH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // -- Panel izquierdo: texto sobre fondo oscuro --
          Expanded(
            flex: isMobile ? 1 : 55,
            child: ColoredBox(
              color: const Color(0xFF0D3B2E),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.07,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1504674900247-0877df9cc836'
                        '?q=20&w=600&auto=format',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 24.0 : 56.0,
                      vertical: 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w900,
                              fontSize: heroFont,
                              color: Colors.white,
                              height: 0.92,
                            ),
                            children: const [
                              TextSpan(text: 'Sabor de casa\n'),
                               TextSpan(
                            text: 'como tú quieras',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                              
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Platos elaborados cada dia con ingredientes frescos del mercado.\n'
                          'Cometelo aqui, llevelatelo o pedimos que llegue a tu puerta.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // -- Panel derecho: foto del plato visible --
          if (!isMobile)
            const Expanded(
              flex: 45,
              child: _HeroFoodImage(),
            ),
        ],
      ),
    );
  }
}

class _HeroFoodImage extends StatelessWidget {
  const _HeroFoodImage();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://images.unsplash.com/photo-1547592180-85f173990554'
          '?q=80&w=1200&auto=format&fit=crop',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Gradiente inferior para legibilidad del texto
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.65),
                ],
                stops: const [0.45, 1.0],
              ),
            ),
          ),
        ),

      ],
    );
  }
}
class _WebPlaceholderImg extends StatelessWidget {
  const _WebPlaceholderImg();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF0F0F0),
      child: Center(
        child: Icon(Icons.restaurant, color: Color(0xFFCCCCCC), size: 40),
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  const _HoverCard({required this.child});

  final Widget child;

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovered ? 1.030 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// â”€â”€ Los más pedidos del mes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€


// ── Platos de la semana ──────────────────────────────────────────────────────

// ── Banner "El sabor de casa" ─────────────────────────────────────────────────

class _WebSaborBanner extends ConsumerWidget {
  const _WebSaborBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discountEnabled =
        ref.watch(firstOrderDiscountEnabledProvider).valueOrNull ?? true;
    return ColoredBox(
      color: const Color(0xFF0D3B2E),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 700;
          final textContent = Padding(
            padding: EdgeInsets.symmetric(
              horizontal: narrow ? 24 : 64,
              vertical: narrow ? 32 : 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: narrow ? 32 : 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                    children: const [
                      TextSpan(text: 'El sabor de '),
                      TextSpan(
                        text: 'casa',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Cocinamos para que disfrutes comiendo comida casera,\nnatural y variada cada semana.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    context.goNamed(RouteNames.menu);
                    if (discountEnabled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '¡Tu 30% se aplicará automáticamente en tu primer pedido!',
                          ),
                          backgroundColor: AppTokens.brandPrimary,
                        ),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTokens.brandPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    shape: const StadiumBorder(),
                    textStyle: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Pruébalo hoy: 30% Dto.'),
                ),
              ],
            ),
          );
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 220,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1574484284002-952d92456975'
                    '?q=80&w=1200&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                textContent,
              ],
            );
          }
          return SizedBox(
            height: 420,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1574484284002-952d92456975'
                    '?q=80&w=1200&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(child: textContent),
              ],
            ),
          );
        },
      ),
    );
  }
}
// ── Más pedidos — sección independiente con carrusel ────────────────────────
class _WebTopDishesCarousel extends ConsumerStatefulWidget {
  const _WebTopDishesCarousel();

  @override
  ConsumerState<_WebTopDishesCarousel> createState() =>
      _WebTopDishesCarouselState();
}

class _WebTopDishesCarouselState
    extends ConsumerState<_WebTopDishesCarousel> {
  late final PageController _pageCtrl;
  int _page = 0;

  /// Cuántas tarjetas se ven a la vez según ancho
  int _visibleCards(double width) {
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    if (width >= 500) return 2;
    return 1;
  }

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _prev() {
    if (_page > 0) {
      setState(() => _page--);
      _pageCtrl.animateToPage(
        _page,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _next(int total) {
    if (_page < total - 1) {
      setState(() => _page++);
      _pageCtrl.animateToPage(
        _page,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dishesAsync = ref.watch(topOrderedDishesProvider);

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Título estilo display serif ──────────────────────
                  Text(
                    'Los más pedidos del mes',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w900,
                      fontSize: 38,
                      letterSpacing: 1.5,
                      color: const Color.fromARGB(255, 9, 9, 9),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── Carrusel ─────────────────────────────────────────
                  dishesAsync.when(
                    data: (dishes) {
                      if (dishes.isEmpty) return const SizedBox.shrink();
                      return LayoutBuilder(builder: (_, constraints) {
                        final visible = _visibleCards(constraints.maxWidth);
                        // Páginas = número de grupos de `visible` tarjetas
                        final pageCount =
                            (dishes.length / visible).ceil();
                        final canPrev = _page > 0;
                        final canNext = _page < pageCount - 1;

                        return Column(
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  height: 330,
                                  child: PageView.builder(
                                    controller: _pageCtrl,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: pageCount,
                                    itemBuilder: (_, pageIdx) {
                                      final start = pageIdx * visible;
                                      final end = (start + visible)
                                          .clamp(0, dishes.length);
                                      final pageDishes =
                                          dishes.sublist(start, end);
                                      return Row(
                                        children: [
                                          for (int i = 0;
                                              i < pageDishes.length;
                                              i++) ...
                                            [
                                              Expanded(
                                                child: _HoverCard(
                                                  child: _TopDishCard(
                                                    dish: pageDishes[i],
                                                    rank: start + i + 1,
                                                  ),
                                                ),
                                              ),
                                              if (i < pageDishes.length - 1)
                                                const SizedBox(width: 20),
                                            ],
                                          // Relleno si última página incompleta
                                          for (int i = pageDishes.length;
                                              i < visible;
                                              i++) ...
                                            [
                                              const Expanded(
                                                  child: SizedBox.shrink()),
                                              if (i < visible - 1)
                                                const SizedBox(width: 20),
                                            ],
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                // Flecha izquierda — discreta, dentro del padding
                                if (canPrev)
                                  Positioned(
                                    left: 8,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: _CarouselArrow(
                                        icon: Icons.arrow_back_ios_new_rounded,
                                        enabled: true,
                                        onTap: _prev,
                                      ),
                                    ),
                                  ),
                                // Flecha derecha — discreta, dentro del padding
                                if (canNext)
                                  Positioned(
                                    right: 8,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: _CarouselArrow(
                                        icon: Icons.arrow_forward_ios_rounded,
                                        enabled: true,
                                        onTap: () => _next(pageCount),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      });
                    },
                    loading: () => SizedBox(
                      height: 330,
                      child: Row(
                        children: List.generate(
                          4,
                          (i) => Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsets.only(right: i < 3 ? 20 : 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white.withValues(alpha: 0.9)
              : const Color(0xFFF5F5F5),
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? AppTokens.brandPrimary.withValues(alpha: 0.5)
                : const Color(0xFFEEEEEE),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 13,
          color: enabled
              ? AppTokens.brandPrimary
              : const Color(0xFFCCCCCC),
        ),
      ),
    );
  }
}

class _TopDishCard extends ConsumerWidget {
  const _TopDishCard({required this.dish, required this.rank});

  final Dish dish;
  final int rank;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => showDishDetailModal(context, dish.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con badge de rango
            Stack(
              children: [
                SizedBox(
                  height: 155,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: dish.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: dish.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) =>
                                const ColoredBox(color: Color(0xFFF0F0F0)),
                            errorWidget: (_, __, ___) =>
                                const _WebPlaceholderImg(),
                          )
                        : const _WebPlaceholderImg(),
                  ),
                ),
                // Gradient overlay on image
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.30),
                        ],
                        stops: const [0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dish.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Estrellas + precio
                  Row(
                    children: [
                      // Estrellas decorativas
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < 4 ? Icons.star : Icons.star_half,
                          color: const Color(0xFFFFC107),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.${8 - rank}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          Formatters.price(dish.price),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTokens.brandPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          ref.read(cartNotifierProvider.notifier).addDish(dish);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${dish.name} añadido'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTokens.brandPrimary,
                          minimumSize: const Size(0, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Añadir',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Banner Catering â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€



// â”€â”€ En oferta â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€



// ─── Banner Encargos ──────────────────────────────────────────────────────────

class _WebEncargosBanner extends StatelessWidget {
  const _WebEncargosBanner();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF1B4332),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 700;
          final textContent = Padding(
            padding: EdgeInsets.symmetric(
              horizontal: narrow ? 24 : 64,
              vertical: narrow ? 32 : 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTokens.brandPrimary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ENCARGOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Encarga con\nantelación',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: narrow ? 28 : 40,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reserva tus platos con antelación y recoge cuando quieras.\nSin esperas, con garantía de disponibilidad.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () => context.goNamed(RouteNames.orders),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1B4332),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: const StadiumBorder(),
                        minimumSize: const Size(0, 48),
                        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Ver mis encargos'),
                    ),
                  ],
                ),
              ],
            ),
          );
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 220,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200&q=80&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                textContent,
              ],
            );
          }
          return SizedBox(
            height: 420,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200&q=80&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(child: textContent),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WebOffersSection extends ConsumerStatefulWidget {
  const _WebOffersSection();

  @override
  ConsumerState<_WebOffersSection> createState() => _WebOffersSectionState();
}

class _WebOffersSectionState extends ConsumerState<_WebOffersSection> {
  late final PageController _pageCtrl;
  int _page = 0;

  int _visibleCards(double width) {
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    if (width >= 500) return 2;
    return 1;
  }

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _prev() {
    if (_page > 0) {
      setState(() => _page--);
      _pageCtrl.animateToPage(
        _page,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _next(int total) {
    if (_page < total - 1) {
      setState(() => _page++);
      _pageCtrl.animateToPage(
        _page,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectionEnabled =
        ref.watch(showOffersSectionProvider).valueOrNull ?? true;
    if (!sectionEnabled) return const SizedBox.shrink();

    final offersAsync = ref.watch(offerDishesProvider);

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descuentos de la semana',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w900,
                      fontSize: 38,
                      letterSpacing: 1.5,
                      color: const Color.fromARGB(255, 9, 9, 9),
                    ),
                  ),
                  const SizedBox(height: 40),
                  offersAsync.when(
                    data: (dishes) {
                      final offers = dishes.take(8).toList();
                      if (offers.isEmpty) return const SizedBox.shrink();
                      return LayoutBuilder(builder: (_, constraints) {
                        final visible = _visibleCards(constraints.maxWidth);
                        final pageCount =
                            (offers.length / visible).ceil();
                        final canPrev = _page > 0;
                        final canNext = _page < pageCount - 1;

                        return Column(
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  height: 330,
                                  child: PageView.builder(
                                    controller: _pageCtrl,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: pageCount,
                                    itemBuilder: (_, pageIdx) {
                                      final start = pageIdx * visible;
                                      final end = (start + visible)
                                          .clamp(0, offers.length);
                                      final pageOffers =
                                          offers.sublist(start, end);
                                      return Row(
                                        children: [
                                          for (int i = 0;
                                              i < pageOffers.length;
                                              i++) ...[
                                            Expanded(
                                              child: _HoverCard(
                                                child: _OfferDishCard(
                                                  dish: pageOffers[i],
                                                ),
                                              ),
                                            ),
                                            if (i < pageOffers.length - 1)
                                              const SizedBox(width: 20),
                                          ],
                                          for (int i = pageOffers.length;
                                              i < visible;
                                              i++) ...[
                                            const Expanded(
                                                child: SizedBox.shrink()),
                                            if (i < visible - 1)
                                              const SizedBox(width: 20),
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                if (canPrev)
                                  Positioned(
                                    left: 8,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: _CarouselArrow(
                                        icon:
                                            Icons.arrow_back_ios_new_rounded,
                                        enabled: true,
                                        onTap: _prev,
                                      ),
                                    ),
                                  ),
                                if (canNext)
                                  Positioned(
                                    right: 8,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: _CarouselArrow(
                                        icon:
                                            Icons.arrow_forward_ios_rounded,
                                        enabled: true,
                                        onTap: () => _next(pageCount),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      });
                    },
                    loading: () => SizedBox(
                      height: 330,
                      child: Row(
                        children: List.generate(
                          4,
                          (i) => Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsets.only(right: i < 3 ? 20 : 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferDishCard extends ConsumerWidget {
  const _OfferDishCard({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasOfferPrice = dish.offerPrice != null;
    return GestureDetector(
      onTap: () => showDishDetailModal(context, dish.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con badge de oferta
            Stack(
              children: [
                SizedBox(
                  height: 155,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: dish.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: dish.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) =>
                                const ColoredBox(color: Color(0xFFF0F0F0)),
                            errorWidget: (_, __, ___) =>
                                const _WebPlaceholderImg(),
                          )
                        : const _WebPlaceholderImg(),
                  ),
                ),
                // Gradient overlay on image
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.30),
                        ],
                        stops: const [0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dish.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Estrellas
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < 4 ? Icons.star : Icons.star_half,
                          color: const Color(0xFFFFC107),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '4.6',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Precio + botÃ³n aÃ±adir
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasOfferPrice) ...[
                              Text(
                                Formatters.price(dish.price),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              Text(
                                Formatters.price(dish.offerPrice!),
                                style: const TextStyle(
                                  color: AppTokens.brandPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                            ] else
                              Text(
                                Formatters.price(dish.price),
                                style: const TextStyle(
                                  color: AppTokens.brandPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          ref.read(cartNotifierProvider.notifier).addDish(dish);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${dish.name} añadido'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTokens.brandPrimary,
                          minimumSize: const Size(0, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Añadir',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sección Platos de Temporada ─────────────────────────────────────────────

class _WebSeasonalSection extends ConsumerWidget {
  const _WebSeasonalSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionEnabled =
        ref.watch(showSeasonalSectionProvider).valueOrNull ?? true;
    if (!sectionEnabled) return const SizedBox.shrink();

    final seasonalAsync = ref.watch(seasonalDishesProvider);

    return seasonalAsync.when(
      data: (dishes) {
        final seasonal = dishes.take(4).toList();
        if (seasonal.length < 3) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF2E7D32),
                    size: 13,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'TEMPORADA',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'PLATOS DE TEMPORADA',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w900, 
                    fontSize: 38,
                    letterSpacing: 1.5,
                    color: const Color(0xFF111111),
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => context.goNamed(RouteNames.menu),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5C9D3E),
                    side: const BorderSide(color: Color(0xFF5C9D3E)),
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Ver todo →'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (_, constraints) {
                final cols = constraints.maxWidth < 450
                    ? 2
                    : constraints.maxWidth < 750
                        ? 3
                        : 4;
                final cardW =
                    (constraints.maxWidth - (cols - 1) * 16) / cols;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: List.generate(
                    seasonal.length,
                    (i) => _HoverCard(
                      child: SizedBox(
                        width: cardW,
                        child: _SeasonalDishCard(dish: seasonal[i]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 280,
        child: Row(
          children: [
            Expanded(child: _SkeletonCard()),
            SizedBox(width: 16),
            Expanded(child: _SkeletonCard()),
            SizedBox(width: 16),
            Expanded(child: _SkeletonCard()),
            SizedBox(width: 16),
            Expanded(child: _SkeletonCard()),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _SeasonalDishCard extends ConsumerWidget {
  const _SeasonalDishCard({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => showDishDetailModal(context, dish.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con badge de temporada
            Stack(
              children: [
                SizedBox(
                  height: 155,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: dish.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: dish.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) =>
                                const ColoredBox(color: Color(0xFFF0F0F0)),
                            errorWidget: (_, __, ___) =>
                                const _WebPlaceholderImg(),
                          )
                        : const _WebPlaceholderImg(),
                  ),
                ),
                // Gradient overlay on image
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.30),
                        ],
                        stops: const [0.55, 1.0],
                      ),
                    ),
                  ),
                ),
                // Badge "TEMPORADA"
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C9D3E),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.eco_rounded, color: Colors.white, size: 11),
                        SizedBox(width: 4),
                        Text(
                          'TEMPORADA',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dish.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Estrellas
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < 4 ? Icons.star : Icons.star_half,
                          color: const Color(0xFFFFC107),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '4.6',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Precio + botón añadir
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          Formatters.price(dish.price),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTokens.brandPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          ref
                              .read(cartNotifierProvider.notifier)
                              .addDish(dish);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${dish.name} añadido'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF5C9D3E),
                          minimumSize: const Size(0, 34),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Añadir',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebCateringBanner extends StatelessWidget {
  const _WebCateringBanner();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF1B4332),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 700;
          final textContent = Padding(
            padding: EdgeInsets.symmetric(
              horizontal: narrow ? 24 : 64,
              vertical: narrow ? 32 : 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTokens.brandPrimary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'CATERING & EVENTOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Organiza tu evento\ncon nosotros',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: narrow ? 28 : 40,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bodas, cumpleaños, reuniones de empresa y mucho más.\nPresupuesto personalizado sin compromiso.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton(
                      onPressed: () => context.goNamed(RouteNames.cateringRequest),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1B4332),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: const StadiumBorder(),
                        minimumSize: const Size(0, 48),
                        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Solicitar presupuesto'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.goNamed(RouteNames.catering),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: const StadiumBorder(),
                        minimumSize: const Size(0, 48),
                        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Ver más'),
                    ),
                  ],
                ),
              ],
            ),
          );
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 220,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?q=80&w=1200&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                textContent,
              ],
            );
          }
          return SizedBox(
            height: 420,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?q=80&w=1200&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(child: textContent),
              ],
            ),
          );
        },
      ),
    );
  }
}
// ── Cómo funciona (rediseñada) ─────────────────────────────────────────────
typedef _StepData = ({
  IconData icon,
  String title,
  String body,
  Color accent,
});

class _WebHowItWorksSection extends StatelessWidget {
  const _WebHowItWorksSection();

  static const List<_StepData> _steps = [
    (
      icon: Icons.restaurant_menu,
      title: 'Mira qué hay hoy',
      body:
          'Cada día cocinamos platos nuevos. Filtra por categoría, consulta ingredientes y alérgenos, y añade lo que te apetezca al carrito.',
      accent: Color(0xFF1D9E75),
    ),
    (
      icon: Icons.storefront,
      title: 'Recógelo en el local',
      body:
          'Ven a nuestro local en Sanlúcar de Barrameda y te lo entregamos recién hecho. Puedes reservar con antelación o venir directamente.',
      accent: Color(0xFF1D9E75),
    ),
    (
      icon: Icons.delivery_dining,
      title: 'O te lo llevamos',
      body:
          'Si prefieres no salir de casa, hacemos envío a domicilio. Elige la franja horaria que mejor te venga y lo recibes caliente.',
      accent: Color(0xFF1D9E75),
    ),
    (
      icon: Icons.cake,
      title: 'Encargos y catering',
      body:
          'Pide para una fecha concreta o solicita un menú completo para tu evento: bodas, comuniones, celebraciones de empresa… lo preparamos todo.',
      accent: Color(0xFF1D9E75),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isDesktop = w >= 860;

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  // ── Cabecera ───────────────────────────────────────
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w900,
                        fontSize: isDesktop ? 54 : 36,
                        height: 1,
                        color: const Color(0xFF111111),
                      ),
                      children: const [
                        TextSpan(text: '¿Cómo '),
                        TextSpan(
                          text: 'funciona',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF1D9E75),
                          ),
                        ),
                        TextSpan(text: '?'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),

                  // ── Stepper ──────────────────────────────────────
                  if (isDesktop)
                    const _DesktopStepper(steps: _steps)
                  else
                    const _MobileStepper(steps: _steps),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stepper desktop ───────────────────────────────────────────────────────────
class _DesktopStepper extends StatelessWidget {
  const _DesktopStepper({required this.steps});

  final List<_StepData> steps;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Expanded(
              child: _StepFeatureCard(step: steps[i], index: i),
            ),
            if (i < steps.length - 1) const SizedBox(width: 32),
          ],
        ],
      ),
    );
  }
}

// Tarjeta estilo feature card (icono cuadrado redondeado + título + texto)
class _StepFeatureCard extends StatelessWidget {
  const _StepFeatureCard({required this.step, required this.index});

  final _StepData step;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 120),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAEAE8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icono cuadrado redondeado ──────────────────────────
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: step.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(step.icon, color: step.accent, size: 28),
            ),
            const SizedBox(height: 24),
            // ── Título ─────────────────────────────────────────────
            Text(
              step.title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: const Color(0xFF111111),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            // ── Descripción ────────────────────────────────────────
            Text(
              step.body,
              textAlign: TextAlign.left,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: const Color(0xFF666666),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stepper mobile ────────────────────────────────────────────────────────────
class _MobileStepper extends StatelessWidget {
  const _MobileStepper({required this.steps});

  final List<_StepData> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _StepFeatureMobile(step: steps[i], index: i),
          if (i < steps.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _StepFeatureMobile extends StatelessWidget {
  const _StepFeatureMobile({required this.step, required this.index});

  final _StepData step;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 100),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEAEAE8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: step.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(step.icon, color: step.accent, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step.body,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF666666),
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebDailyMenuSection extends ConsumerStatefulWidget {
  const _WebDailyMenuSection();

  @override
  ConsumerState<_WebDailyMenuSection> createState() =>
      _WebDailyMenuSectionState();
}

class _WebDailyMenuSectionState extends ConsumerState<_WebDailyMenuSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specialAsync = ref.watch(dailySpecialNotifierProvider);
    return specialAsync.when(
      data: (special) {
        if (special == null) return const SizedBox.shrink();
        // Arranca la animación la primera vez que hay datos.
        if (!_ctrl.isCompleted && !_ctrl.isAnimating) _ctrl.forward();
        return FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _slide,
            child: _DailyMenuLayout(special: special),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _DailyMenuLayout extends StatelessWidget {
  const _DailyMenuLayout({required this.special});

  final DailySpecial special;

  static const _accent = Color(0xFF7BC8A4);
  static const _defaultPhoto =
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=900&q=80';

  @override
  Widget build(BuildContext context) {
    final imageUrl = special.imageUrl ?? _defaultPhoto;

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                // ── Título FUERA del marco ────────────────────────────
                const _DailyMenuHeader(),
                const SizedBox(height: 16),
                // ── Tarjeta con marco verde ───────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _accent, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.12),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 640;
                      if (isWide) {
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 55,
                                child: _MenuPanel(special: special),
                              ),
                              Expanded(
                                flex: 45,
                                child: _DailyFoodImage(imageUrl: imageUrl),
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 260,
                            child: _DailyFoodImage(imageUrl: imageUrl),
                          ),
                          _MenuPanel(special: special),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Encabezado FUERA del marco ────────────────────────────────────────────────

class _DailyMenuHeader extends StatelessWidget {
  const _DailyMenuHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Día de la semana en pequeño
        Text(
          _todayLabel(),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTokens.brandPrimary,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        // Título principal
        Text(
          'Menú del Día',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 52,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
            height: 1.05,
          ),
        ),
        const SizedBox(height: 12),
        // Lema
        Text(
          'Cocinado hoy, para disfrutar hoy.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF757575),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  static String _todayLabel() {
    const dias = [
      'LUNES',
      'MARTES',
      'MIÉRCOLES',
      'JUEVES',
      'VIERNES',
      'SÁBADO',
      'DOMINGO',
    ];
    const meses = [
      'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
      'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE',
    ];
    final now = DateTime.now();
    return '${dias[now.weekday - 1]}, ${now.day} DE ${meses[now.month - 1]}';
  }
}

// ── Panel de menú (izquierda) ─────────────────────────────────────────────────

class _MenuPanel extends ConsumerWidget {
  const _MenuPanel({required this.special});

  final DailySpecial special;

  static const _accent = Color(0xFF7BC8A4);
  static const _labelColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Platos ───────────────────────────────────────────────────
          if (special.primeroText != null)
            _MenuCourse(label: 'Primer plato', value: special.primeroText!),
          if (special.segundoText != null)
            _MenuCourse(label: 'Segundo plato', value: special.segundoText!),
          if (special.postreText != null)
            _MenuCourse(label: 'Postre', value: special.postreText!),
          if (special.bebidaText != null)
            _MenuCourse(label: 'Bebida', value: special.bebidaText!),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 20),
          // ── Nota adicional ────────────────────────────────────────────
          if (special.note != null && special.note!.trim().isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppTokens.brandPrimary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      special.note!.trim(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTokens.brandDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // ── Precio + botón ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (special.menuPrice != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Formatters.price(special.menuPrice!),
                      style: GoogleFonts.inter(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppTokens.brandPrimary,
                        height: 1,
                      ),
                    ),
                    const Text(
                      'por persona',
                      style: TextStyle(
                        fontSize: 12,
                        color: _labelColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
              ],
              FilledButton(
                onPressed: special.menuPrice == null
                    ? null
                    : () {
                        ref.read(cartNotifierProvider.notifier).addItem(
                          CartItem(
                            dishId: special.id,
                            name: 'Menú del día',
                            unitPrice: special.menuPrice!,
                            quantity: 1,
                            imageUrl: special.imageUrl,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Menú del día añadido al carrito',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                            backgroundColor: AppTokens.brandPrimary,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.brandPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 14,
                  ),
                  shape: const StadiumBorder(),
                  minimumSize: const Size(0, 46),
                ),
                child: Text(
                  'Pedir ahora',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}

class _MenuCourse extends StatelessWidget {
  const _MenuCourse({required this.label, required this.value});

  final String label;
  final String value;

  static const _labelColor = Color(0xFF9E9E9E);
  static const _valueColor = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, left: 16, right: 16),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _labelColor,
              letterSpacing: 1.2,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _valueColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade100),
        ],
      ),
    );
  }
}

// ── Foto (derecha) ────────────────────────────────────────────────────────────

class _DailyFoodImage extends StatelessWidget {
  const _DailyFoodImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      placeholder: (_, __) => const SizedBox.shrink(),
      errorWidget: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}

// -- Testimonios -------------------------------------------------------------

// ── Sección de testimonios ─────────────────────────────────────────────────

class _WebTestimonialsSection extends StatefulWidget {
  const _WebTestimonialsSection();

  @override
  State<_WebTestimonialsSection> createState() =>
      _WebTestimonialsSectionState();
}

class _WebTestimonialsSectionState extends State<_WebTestimonialsSection> {
  // TODO: Reemplazar con datos reales de Supabase (valoraciones 5 estrellas)
  static const _reviews = [
    (
      author: 'Mar\u00eda G.',
      text:
          'La mejor comida casera de Sanl\u00facar. El pollo asado es espectacular, '
          'igual que el de mi abuela. Llevo meses pidiendo cada semana.',
      rating: 5,
    ),
    (
      author: 'Carlos R.',
      text:
          'Pedimos catering para la comuni\u00f3n de mi hija y fue todo un \u00e9xito. '
          'La organizaci\u00f3n perfecta y la comida deliciosa.',
      rating: 5,
    ),
    (
      author: 'Ana L.',
      text:
          'Los encargos son comod\u00edsimos. Dejo el pedido el d\u00eda anterior y lo '
          'recojo reci\u00e9n hecho. Sin colas, sin esperas.',
      rating: 5,
    ),
  ];

  static const _bullets = [
    ('M\u00e1s de 500 familias', 'ya conf\u00edan en nuestra cocina cada semana.'),
    ('Despreoc\u00fapate', 'de cocinar, sin dejar de comer bien.'),
    ('Ingredientes frescos', 'elaborados a diario, sin conservantes.'),
  ];

  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 56),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 680;
                  final itemsPerPage = isWide ? 2 : 1;
                  final totalPages =
                      (_reviews.length / itemsPerPage).ceil();

                  final mainContent = _buildMainContent(
                    constraints,
                    isWide,
                    itemsPerPage,
                    totalPages,
                  );

                  if (!isWide) return mainContent;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 6, child: mainContent),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 260,
                        child: Image.asset(
                          'assets/images/movilopiniones.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BoxConstraints outerConstraints,
    bool isWide,
    int itemsPerPage,
    int totalPages,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(
                5,
                (_) => const Icon(
                  Icons.star,
                  color: Color(0xFFFFC107),
                  size: 13,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '4.9 \u00b7 Valoraciones de clientes',
                style: TextStyle(
                  color: Color(0xFF7B5000),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // T\u00edtulo
        Text(
          'Lo que dicen\nnuestros clientes',
          style: GoogleFonts.inter(
            fontSize: isWide ? 30 : 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
            height: 1.15,
            color: const Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 16),
        // Bullets
        ..._bullets.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.check_circle,
                    size: 15,
                    color: AppTokens.brandPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${b.$1} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF111111),
                          ),
                        ),
                        TextSpan(
                          text: b.$2,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Carrusel
        LayoutBuilder(
          builder: (context, constraints) {
            const arrowW = 36.0;
            const arrowSpacing = 8.0;
            const cardSpacing = 16.0;
            final carouselW =
                constraints.maxWidth - (arrowW + arrowSpacing) * 2;
            final cardW = itemsPerPage == 1
                ? carouselW
                : (carouselW - cardSpacing) / 2;

            final start = _page * itemsPerPage;
            final end = (start + itemsPerPage).clamp(0, _reviews.length);
            final pageReviews = _reviews.sublist(start, end);

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flecha izquierda
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24,
                        right: arrowSpacing,
                      ),
                      child: _ArrowButton(
                        icon: Icons.chevron_left,
                        enabled: _page > 0,
                        onTap: () => setState(() => _page--),
                      ),
                    ),
                    // Cards
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Row(
                          key: ValueKey(_page),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < pageReviews.length; i++) ...[
                              if (i > 0) const SizedBox(width: cardSpacing),
                              SizedBox(
                                width: cardW,
                                child: _ReviewCard(review: pageReviews[i]),
                              ),
                            ],
                            if (pageReviews.length < itemsPerPage)
                              SizedBox(width: cardW + cardSpacing),
                          ],
                        ),
                      ),
                    ),
                    // Flecha derecha
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24,
                        left: arrowSpacing,
                      ),
                      child: _ArrowButton(
                        icon: Icons.chevron_right,
                        enabled: _page < totalPages - 1,
                        onTap: () => setState(() => _page++),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Puntos indicadores
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalPages,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: i == _page
                            ? AppTokens.brandPrimary
                            : const Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (!isWide) ...[
          const SizedBox(height: 24),
          Center(
            child: Image.asset(
              'assets/images/movilopiniones.png',
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? AppTokens.brandPrimary : const Color(0xFFE0E0E0),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : const Color(0xFFAAAAAA),
          size: 20,
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ({String author, String text, int rating}) review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppTokens.brandPrimary, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(
              review.rating,
              (_) => const Icon(
                Icons.star,
                color: Color(0xFFFFC107),
                size: 15,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '"${review.text}"',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF333330),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '\u2014 ${review.author}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTokens.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
// -- Suscripcion -------------------------------------------------------------

class _WebSubscriptionSection extends ConsumerStatefulWidget {
  const _WebSubscriptionSection();

  @override
  ConsumerState<_WebSubscriptionSection> createState() =>
      _WebSubscriptionSectionState();
}

class _WebSubscriptionSectionState
    extends ConsumerState<_WebSubscriptionSection> {
  bool _isWhatsApp = false;
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(subscriptionNotifierProvider.notifier).subscribe(
          type: _isWhatsApp ? 'whatsapp' : 'email',
          email: _isWhatsApp ? null : _ctrl.text.trim(),
          phone: _isWhatsApp ? _ctrl.text.trim() : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(subscriptionNotifierProvider);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D3B2E), Color(0xFF0A2F24)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 72),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 700;

                final textBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge superior
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTokens.brandPrimary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTokens.brandPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        'NEWSLETTER',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF7FFFC4),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Título
                    Text(
                      '¿Quieres recibir\nel menú del día?',
                      style: GoogleFonts.inter(
                        fontSize: narrow ? 30 : 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Descripción
                    Text(
                      'Suscríbete y recibe el menú, las ofertas especiales '
                      'y las novedades directamente en tu correo o WhatsApp. '
                      'Sin spam, solo lo que importa.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.70),
                        height: 1.75,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Pills de características
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _SubBadge(label: 'Menú del día'),
                        _SubBadge(label: 'Ofertas especiales'),
                        _SubBadge(label: 'Novedades'),
                      ],
                    ),
                    if (!narrow) ...[
                      const SizedBox(height: 36),
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            color: Color(0xFF7FFFC4),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Más de 500 familias ya suscritas',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );

                final formBlock = Container(
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 48,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: status == SubscriptionStatus.done
                      ? const _SubscribedMessage()
                      : Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Elige cómo quieres recibir las novedades',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111111),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Toggles Email / WhatsApp
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _TypeToggle(
                                        label: 'Email',
                                        icon: Icons.email_outlined,
                                        selected: !_isWhatsApp,
                                        onTap: () => setState(() {
                                          _isWhatsApp = false;
                                          _ctrl.clear();
                                        }),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: _TypeToggle(
                                        label: 'WhatsApp',
                                        icon: Icons.chat_bubble_outline,
                                        selected: _isWhatsApp,
                                        onTap: () => setState(() {
                                          _isWhatsApp = true;
                                          _ctrl.clear();
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Campo de entrada
                              TextFormField(
                                controller: _ctrl,
                                keyboardType: _isWhatsApp
                                    ? TextInputType.phone
                                    : TextInputType.emailAddress,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: const Color(0xFF111111),
                                ),
                                decoration: InputDecoration(
                                  hintText: _isWhatsApp
                                      ? 'Tu número de WhatsApp'
                                      : 'Tu correo electrónico',
                                  hintStyle: GoogleFonts.inter(
                                    color: const Color(0xFFAAAAAA),
                                    fontSize: 14,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF7F7F5),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE8E8E6),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppTokens.brandPrimary,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 14,
                                      right: 10,
                                    ),
                                    child: Icon(
                                      _isWhatsApp
                                          ? Icons.chat_bubble_outline
                                          : Icons.email_outlined,
                                      color: AppTokens.brandPrimary,
                                      size: 20,
                                    ),
                                  ),
                                  prefixIconConstraints:
                                      const BoxConstraints(minWidth: 0),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return _isWhatsApp
                                        ? 'Introduce tu número'
                                        : 'Introduce tu correo';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 52,
                                child: status == SubscriptionStatus.loading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                              AppTokens.brandPrimary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: _subscribe,
                                        child: Text(
                                          'SUSCRIBIRME',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.5,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                              if (status == SubscriptionStatus.error) ...[
                                const SizedBox(height: 10),
                                const Text(
                                  'Ha ocurrido un error. Inténtalo de nuevo.',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.lock_outline,
                                    size: 13,
                                    color: Color(0xFFAAAAAA),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Sin spam. Cancela cuando quieras.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFFAAAAAA),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                );

                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      textBlock,
                      const SizedBox(height: 36),
                      formBlock,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 5, child: textBlock),
                    const SizedBox(width: 64),
                    Expanded(flex: 5, child: formBlock),
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

class _SubBadge extends StatelessWidget {
  const _SubBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 14,
            color: Color(0xFF7FFFC4),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscribedMessage extends StatelessWidget {
  const _SubscribedMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTokens.brandPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppTokens.brandPrimary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Suscripción confirmada!',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTokens.brandDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pronto recibirás las novedades de Sabor de Casa.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF2D5E4F),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppTokens.brandPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTokens.brandPrimary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? Colors.white : const Color(0xFF666666),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.inter(
                color: selected ? Colors.white : const Color(0xFF666666),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebCartDrawer extends ConsumerWidget {
  const _WebCartDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartItemsProvider);
    final total = ref.watch(cartTotalProvider);

    void close() => Scaffold.of(context).closeEndDrawer();

    return Material(
      color: Colors.white,
      elevation: 16,
      child: SizedBox(
        width: 440,
        child: Column(
          children: [
            // ── Cabecera ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 52, 12, 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E5E3)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 22,
                    color: AppTokens.brandPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'MI CARRITO',
                      style: GoogleFonts.inter(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: close,
                  ),
                ],
              ),
            ),

            // ── Contenido ─────────────────────────────────────────────────
            if (items.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 56,
                        color: Color(0xFFCCCCCC),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tu carrito está vacío',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final item = items[i];
                  return _DrawerCartItem(
                    item: item,
                    onIncrement: () => ref
                        .read(cartNotifierProvider.notifier)
                        .incrementItem(item.dishId),
                    onDecrement: () => ref
                        .read(cartNotifierProvider.notifier)
                        .decrementItem(item.dishId),
                    onRemove: () => ref
                        .read(cartNotifierProvider.notifier)
                        .removeItem(item.dishId),
                  );
                },
              ),
            ),

            // ── Pie: total + botones ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E5E3)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        Formatters.price(total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: AppTokens.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      close();
                      context.goNamed(RouteNames.checkout);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTokens.brandPrimary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Ir al pago'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: close,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTokens.brandPrimary,
                      side: const BorderSide(color: AppTokens.brandPrimary),
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Seguir comprando'),
                  ),
                ],
              ),
            ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrawerCartItem extends StatelessWidget {
  const _DrawerCartItem({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 64,
                    height: 64,
                    color: const Color(0xFFE5E5E3),
                    child: const Icon(Icons.fastfood, color: Colors.black38),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.price(item.unitPrice),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: item.quantity > 1 ? onDecrement : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _QtyButton(icon: Icons.add, onTap: onIncrement),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.price(item.unitPrice * item.quantity),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTokens.brandPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? const Color(0xFFCCCCCC) : const Color(0xFFEEEEEE),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 14,
          color: enabled ? const Color(0xFF333333) : Colors.black26,
        ),
      ),
    );
  }
}

// ── Footer Web ────────────────────────────────────────────────────────────────

class _WebFooter extends StatelessWidget {
  const _WebFooter();

  static const _bg = Color(0xFF0D3B2E);
  static const _bgCard = Color(0xFF0F4433);
  static const _muted = Color(0xFF8FBFB0);
  static const _divider = Color(0xFF1A5C47);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Cuerpo: 4 columnas ──────────────────────────────────────────
          LayoutBuilder(
            builder: (context, lc) {
              final narrow = lc.maxWidth < 700;
              final hPad = narrow ? 20.0 : 48.0;
              final colW = narrow ? (lc.maxWidth - hPad * 2 - 24) / 2 : 0.0;
              final col1 = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conócenos',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sabor de Casa es tu servicio de comida casera '
                    'de confianza en Sanlúcar de Barrameda. Platos '
                    'elaborados a diario con ingredientes frescos, sin '
                    'conservantes, para que comas rico cada día.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _muted,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recogida en local, encargo previo o entrega a domicilio.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _muted,
                      height: 1.7,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              );
              final col2 = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navegación',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FooterLink(
                    label: 'Menú del día',
                    onTap: () => context.goNamed(RouteNames.menu),
                  ),
                  _FooterLink(
                    label: 'Catering y eventos',
                    onTap: () => context.goNamed(RouteNames.catering),
                  ),
                  _FooterLink(
                    label: 'Mis pedidos',
                    onTap: () => context.goNamed(RouteNames.orders),
                  ),
                  _FooterLink(
                    label: 'Mi perfil',
                    onTap: () => context.goNamed(RouteNames.profile),
                  ),
                  _FooterLink(
                    label: 'Contacto',
                    onTap: () => context.goNamed(RouteNames.contact),
                  ),
                ],
              );
              final col3 = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contacto',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _FooterInfoRow(
                    icon: Icons.location_on_outlined,
                    text: 'Sanlúcar de Barrameda, Cádiz',
                  ),
                  const SizedBox(height: 10),
                  const _FooterInfoRow(
                    icon: Icons.phone_outlined,
                    text: '956 36 30 09',
                  ),
                  const SizedBox(height: 10),
                  const _FooterInfoRow(
                    icon: Icons.email_outlined,
                    text: 'info@sabordecasa.es',
                  ),
                  const SizedBox(height: 10),
                  const _FooterInfoRow(
                    icon: Icons.access_time_outlined,
                    text: 'Lun – Sáb: 12:00 – 16:00',
                  ),
                ],
              );
              final col4 = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _bgCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SocialCircle(
                      icon: Icons.facebook,
                      tooltip: 'Facebook',
                    ),
                    _SocialCircle(
                      icon: Icons.camera_alt_outlined,
                      tooltip: 'Instagram',
                    ),
                    _SocialCircle(
                      icon: Icons.alternate_email,
                      tooltip: 'Email',
                    ),
                  ],
                ),
              );
              return Padding(
                padding: EdgeInsets.fromLTRB(hPad, 64, hPad, 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: narrow
                        ? Wrap(
                            spacing: 24,
                            runSpacing: 32,
                            children: [
                              SizedBox(width: colW, child: col1),
                              SizedBox(width: colW, child: col2),
                              SizedBox(width: colW, child: col3),
                              SizedBox(width: colW, child: col4),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: col1),
                              const SizedBox(width: 48),
                              Expanded(flex: 2, child: col2),
                              const SizedBox(width: 48),
                              Expanded(flex: 2, child: col3),
                              const SizedBox(width: 48),
                              SizedBox(width: 280, child: col4),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),

          // ── Divisor ─────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Divider(color: _divider, height: 1),
          ),

          // ── Nombre de marca centrado ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Sabor de Casa',
                  style: GoogleFonts.syne(
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    fontSize: 72,
                    letterSpacing: 0,
                    height: 1,
                    color: AppTokens.brandPrimary,
                  ),
                ),
              ),
            ),
          ),

          // ── Barra legal ──────────────────────────────────────────────────
          LayoutBuilder(
            builder: (context, lc) {
              final narrow = lc.maxWidth < 700;
              final hPad = narrow ? 20.0 : 48.0;
              const links = Wrap(
                spacing: 24,
                runSpacing: 8,
                children: [
                  _LegalLink(label: 'Aviso legal'),
                  _LegalLink(label: 'Privacidad'),
                  _LegalLink(label: 'Cookies'),
                  _LegalLink(label: 'Términos y condiciones'),
                  _LegalLink(label: 'Preguntas frecuentes'),
                ],
              );
              final copyright = Text(
                'Copyright \u00a9 ${DateTime.now().year} Sabor de Casa. '
                'Todos los derechos reservados.',
                style: const TextStyle(color: _muted, fontSize: 12),
              );
              return Padding(
                padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 36),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: narrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              links,
                              const SizedBox(height: 12),
                              copyright,
                            ],
                          )
                        : Row(
                            children: [
                              const Expanded(child: links),
                              copyright,
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Helpers del Footer ────────────────────────────────────────────────────────

class _FooterLink extends StatefulWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _hover ? Colors.white : const Color(0xFF8FBFB0),
              fontWeight: _hover ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterInfoRow extends StatelessWidget {
  const _FooterInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppTokens.brandPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF8FBFB0),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialCircle extends StatefulWidget {
  const _SocialCircle({required this.icon, required this.tooltip});

  final IconData icon;
  final String tooltip;

  @override
  State<_SocialCircle> createState() => _SocialCircleState();
}

class _SocialCircleState extends State<_SocialCircle> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                _hover ? AppTokens.brandPrimary : const Color(0xFF1A5C47),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 17),
        ),
      ),
    );
  }
}

class _LegalLink extends StatefulWidget {
  const _LegalLink({required this.label});

  final String label;

  @override
  State<_LegalLink> createState() => _LegalLinkState();
}

class _LegalLinkState extends State<_LegalLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Text(
        widget.label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: _hover ? Colors.white : const Color(0xFF8FBFB0),
        ),
      ),
    );
  }
}

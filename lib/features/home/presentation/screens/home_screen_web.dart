import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/app_logo_text.dart';
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
      backgroundColor: const Color(0xFFF5F5F5),
      endDrawer: const _WebCartDrawer(),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 120), // offset navbar fija
                _WebHero(),
            const _WebHowItWorksSection(),
            const _WebDailyMenuSection(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 56),
                      _WebTopDishesSection(),
                      SizedBox(height: 56),
                      _WebOffersSection(),
                      SizedBox(height: 56),
                      _WebCateringBanner(),
                      SizedBox(height: 56),
                      _WebTestimonialsSection(),
                      SizedBox(height: 56),
                      _WebEncargosBanner(),
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
            const _WebFooter(),
          ],
        ),
          ),
          // Navbar fija superpuesta
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _WebNavbar(isScrolled: _isScrolled),
          ),
        ],
      ),
    );
  }
}

// ── Navbar Web ────────────────────────────────────────────────────────────

class _WebNavbar extends ConsumerWidget {
  const _WebNavbar({required this.isScrolled});

  final bool isScrolled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final cartCount = ref.watch(cartItemsCountProvider);
    final profile = authState.valueOrNull;

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
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: SizedBox(
            height: 120,
            child: Row(
              children: [
                // Logo
                GestureDetector(
                  onTap: () => context.goNamed(RouteNames.home),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/logo_bueno.png',
                        height: 96,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SABOR DE CASA',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 38,
                              letterSpacing: 2.5,
                              height: 1,
                              color: AppTokens.brandPrimary,
                            ),
                          ),
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
                      ),
                    ],
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
                    label: 'Plato del dia',
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
                if (profile == null) ...[
                  OutlinedButton(
                    onPressed: () => context.goNamed(RouteNames.login),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTokens.brandPrimary,
                      side: const BorderSide(color: AppTokens.brandPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      textStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
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
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      textStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    child: const Text('Registrarse'),
                  ),
                ] else
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
    final heroFont = screenW < 768 ? 60.0 : 88.0;
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTokens.brandPrimary.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'COCINA DE VERDAD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'SABOR DE CASA\nCOMO TU QUIERAS',
                          style: GoogleFonts.bebasNeue(
                            fontSize: heroFont,
                            color: Colors.white,
                            letterSpacing: 2,
                            height: 0.92,
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FilledButton(
                              onPressed: () =>
                                  context.goNamed(RouteNames.menu),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0D3B2E),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: const StadiumBorder(),
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                'VER EL MENU',
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 18,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () =>
                                  context.goNamed(RouteNames.catering),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: const StadiumBorder(),
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                'CATERING',
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 18,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
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

class _WebTopDishesSection extends ConsumerWidget {
  const _WebTopDishesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesAsync = ref.watch(dishesProvider());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: Color(0xFFE65100),
                size: 13,
              ),
              SizedBox(width: 5),
              Text(
                'TENDENCIA',
                style: TextStyle(
                  color: Color(0xFFE65100),
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
              'LOS MÁS PEDIDOS DEL MES',
              style: GoogleFonts.bebasNeue(
                fontSize: 38,
                letterSpacing: 1.5,
                color: const Color(0xFF111111),
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => context.goNamed(RouteNames.menu),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTokens.brandPrimary,
                side: const BorderSide(color: AppTokens.brandPrimary),
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

        // Tarjetas
        dishesAsync.when(
          data: (dishes) {
            final top = dishes.where((d) => d.isAvailable).take(4).toList();
            if (top.isEmpty) return const SizedBox.shrink();
            return LayoutBuilder(
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
                    top.length,
                    (i) => _HoverCard(
                      child: SizedBox(
                        width: cardW,
                        child: _TopDishCard(dish: top[i], rank: i + 1),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => SizedBox(
            height: 280,
            child: Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 3 ? 16 : 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
    );
  }
}

class _TopDishCard extends ConsumerWidget {
  const _TopDishCard({required this.dish, required this.rank});

  final Dish dish;
  final int rank;

  static const _rankColors = [
    Color(0xFFFFD700), // oro
    Color(0xFFC0C0C0), // plata
    Color(0xFFCD7F32), // bronce
    Color(0xFFE5E5E3), // 4.Âº
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        RouteNames.dishDetail,
        pathParameters: {'dishId': dish.id},
      ),
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
                  height: 200,
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
                // Badge de rango
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _rankColors[rank - 1],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: rank == 1
                            ? const Color(0xFF7B5000)
                            : rank == 4
                            ? const Color(0xFF111111)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                // Badge "Más pedido" sólo para el #1
                if (rank == 1)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTokens.brandPrimary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 11),
                          SizedBox(width: 3),
                          Text(
                            'Favorito',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Fondo decorativo
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 360,
            child: Opacity(
              opacity: 0.12,
              child: Image.network(
                'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?q=80&w=800&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
            child: Row(
              children: [
                // Texto + CTA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
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
                        'ENCARGA CON\nANTELACIÓN',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 48,
                          letterSpacing: 1.5,
                          color: Colors.white,
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Reserva tus platos con antelación y recoge cuando quieras.\nSin esperas, con garantía de disponibilidad.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.80),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          FilledButton(
                            onPressed: () =>
                                context.goNamed(RouteNames.orders),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1B4332),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              'Ver mis encargos',
                              style: GoogleFonts.bebasNeue(
                                fontSize: 16,
                                letterSpacing: 1.5,
                                color: const Color(0xFF1B4332),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Imagen decorativa - solo en pantallas anchas
                if (MediaQuery.sizeOf(context).width >= 700)
                  Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: SizedBox(
                      width: 280,
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?q=80&w=800&auto=format&fit=crop',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _WebOffersSection extends ConsumerWidget {
  const _WebOffersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Respeta el toggle global del admin
    final sectionEnabled = ref.watch(showOffersSectionProvider).valueOrNull ?? true;
    if (!sectionEnabled) return const SizedBox.shrink();

    final offersAsync = ref.watch(offerDishesProvider);

    return offersAsync.when(
      data: (dishes) {
        final offers = dishes.take(4).toList();
        if (offers.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_offer_rounded,
                    color: Color(0xFFB71C1C),
                    size: 13,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'OFERTAS',
                    style: TextStyle(
                      color: Color(0xFFB71C1C),
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
                  'EN OFERTA',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 38,
                    letterSpacing: 1.5,
                    color: const Color(0xFF111111),
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => context.goNamed(RouteNames.menu),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    side: const BorderSide(color: Color(0xFFE53935)),
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Ver todo u2192'),
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
                    offers.length,
                    (i) => _HoverCard(
                      child: SizedBox(
                        width: cardW,
                        child: _OfferDishCard(dish: offers[i]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => SizedBox(
        height: 280,
        child: Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? 16 : 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
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
      onTap: () => context.pushNamed(
        RouteNames.dishDetail,
        pathParameters: {'dishId': dish.id},
      ),
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
                  height: 200,
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
                // Badge "OFERTA"
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Text(
                      'OFERTA',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Badge de descuento si hay precio de oferta
                if (hasOfferPrice)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4444),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '-%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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
                            const SnackBar(
                              content: Text(' aÃ±adido'),
                              duration: Duration(seconds: 1),
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
                          'AÃ±adir',
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
                  style: GoogleFonts.bebasNeue(
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
      onTap: () => context.pushNamed(
        RouteNames.dishDetail,
        pathParameters: {'dishId': dish.id},
      ),
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
                  height: 200,
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Fondo decorativo
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 360,
            child: Opacity(
              opacity: 0.12,
              child: Image.network(
                'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=800&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
            child: Row(
              children: [
                // Texto + CTA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
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
                        'ORGANIZA TU EVENTO\nCON NOSOTROS',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 48,
                          letterSpacing: 1.5,
                          color: Colors.white,
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bodas, cumpleaños, reuniones de empresa y mucho más.\nPresupuesto personalizado sin compromiso.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.80),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          FilledButton(
                            onPressed: () =>
                                context.goNamed(RouteNames.cateringRequest),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1B4332),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              'Solicitar presupuesto',
                              style: GoogleFonts.bebasNeue(
                                fontSize: 16,
                                letterSpacing: 1.5,
                                color: const Color(0xFF1B4332),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () =>
                                context.goNamed(RouteNames.catering),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              'Ver más',
                              style: GoogleFonts.bebasNeue(
                                fontSize: 16,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Imagen plato decorativa - solo en pantallas anchas
                if (MediaQuery.sizeOf(context).width >= 700)
                  Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: SizedBox(
                      width: 280,
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?q=80&w=800&auto=format&fit=crop',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _WebHowItWorksSection extends StatelessWidget {
  const _WebHowItWorksSection();

  static const _steps = [
    (
      icon: Icons.restaurant_menu_rounded,
      title: 'Elige tus platos',
      body: 'Explora el menu y filtra por categoria, recetas de toda la vida.',
      color: Color(0xFF1D9E75),
    ),
    (
      icon: Icons.soup_kitchen_rounded,
      title: 'Cocinamos para ti',
      body: 'Ingredientes frescos, sin conservantes ni aditivos. Como en casa.',
      color: Color(0xFF0F6E56),
    ),
    (
      icon: Icons.storefront_rounded,
      title: 'Recoge o enviamos',
      body: 'Pasa por el local, encargalo para llevar o pedimos que llegue a tu puerta.',
      color: Color(0xFF1D9E75),
    ),
    (
      icon: Icons.sentiment_very_satisfied_rounded,
      title: 'A disfrutar',
      body: 'Comida de verdad lista en minutos. Sabor de casa en cada bocado.',
      color: Color(0xFF0F6E56),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 860;

    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFF7F7F5)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  // ── Cabecera ───────────────────────────────────────
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTokens.brandPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ASI DE FACIL',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: AppTokens.brandPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Como funciona',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 52,
                          letterSpacing: 1.5,
                          height: 1,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Del pedido a tu mesa en cuatro pasos.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF888888),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 56),

                  // ── Pasos ─────────────────────────────────────────
                  if (compact)
                    Column(
                      children: List.generate(_steps.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _HowItWorksCard(
                            step: _steps[i],
                            index: i,
                            compact: true,
                          ),
                        );
                      }),
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(_steps.length * 2 - 1, (i) {
                        // Conectores alternos
                        if (i.isOdd) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 44),
                              child: Row(
                                children: List.generate(
                                  6,
                                  (_) => Expanded(
                                    child: Container(
                                      height: 2,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTokens.brandPrimary
                                            .withValues(alpha: 0.25),
                                        borderRadius:
                                            BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        final idx = i ~/ 2;
                        return Expanded(
                          flex: 5,
                          child: _HowItWorksCard(
                            step: _steps[idx],
                            index: idx,
                            compact: false,
                          ),
                        );
                      }),
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

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard({
    required this.step,
    required this.index,
    required this.compact,
  });

  final ({
    IconData icon,
    String title,
    String body,
    Color color,
  }) step;
  final int index;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 120),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child),
      ),
      child: compact
          ? _CompactCard(step: step, index: index)
          : _DesktopCard(step: step, index: index),
    );
  }
}

class _DesktopCard extends StatelessWidget {
  const _DesktopCard({required this.step, required this.index});

  final ({IconData icon, String title, String body, Color color}) step;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icono circular
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: step.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: step.color.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(step.icon, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 6),
        // Numero
        Text(
          '0${index + 1}',
          style: GoogleFonts.bebasNeue(
            fontSize: 13,
            letterSpacing: 2,
            color: AppTokens.brandPrimary.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 16),
        // Titulo
        Text(
          step.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111111),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        // Cuerpo
        Text(
          step.body,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF777777),
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _CompactCard extends StatelessWidget {
  const _CompactCard({required this.step, required this.index});

  final ({IconData icon, String title, String body, Color color}) step;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E6)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: step.color,
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF777777),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _WebDailyMenuSection extends ConsumerWidget {
  const _WebDailyMenuSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialAsync = ref.watch(dailySpecialNotifierProvider);
    return specialAsync.when(
      data: (special) {
        if (special == null) return const SizedBox.shrink();
        return _WebDailyMenuBody(special: special);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _WebDailyMenuBody extends ConsumerWidget {
  const _WebDailyMenuBody({required this.special});

  final DailySpecial special;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishAsync = ref.watch(dishDetailProvider(special.dishId));
    return dishAsync.when(
      data: (dish) {
        return ColoredBox(
          color: AppTokens.brandDark,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 72),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTokens.brandPrimary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'MENU DEL DIA',
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
                              dish.name.toUpperCase(),
                              style: GoogleFonts.bebasNeue(
                                fontSize: 48,
                                color: Colors.white,
                                height: 0.95,
                                letterSpacing: 1.5,
                              ),
                            ),
                            if (special.note != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                special.note!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                            const SizedBox(height: 28),
                            if (special.primeroText != null)
                              _MenuCourseRow(
                                label: 'Primero',
                                value: special.primeroText!,
                              ),
                            if (special.segundoText != null)
                              _MenuCourseRow(
                                label: 'Segundo',
                                value: special.segundoText!,
                              ),
                            if (special.postreText != null)
                              _MenuCourseRow(
                                label: 'Postre',
                                value: special.postreText!,
                              ),
                            if (special.bebidaText != null)
                              _MenuCourseRow(
                                label: 'Bebida',
                                value: special.bebidaText!,
                              ),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                if (special.menuPrice != null) ...[
                                  Text(
                                    Formatters.price(special.menuPrice!),
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 42,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                ],
                                FilledButton(
                                  onPressed: () =>
                                      context.goNamed(RouteNames.menu),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppTokens.brandDark,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: Size.zero,
                                  ),
                                  child: Text(
                                    'PEDIR AHORA',
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 16,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (MediaQuery.sizeOf(context).width >= 700)
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 48),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: dish.imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: dish.imageUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            const ColoredBox(
                                          color: Color(0xFF0D4A3D),
                                        ),
                                        errorWidget: (_, __, ___) =>
                                            const ColoredBox(
                                          color: Color(0xFF0D4A3D),
                                        ),
                                      )
                                    : const ColoredBox(
                                        color: Color(0xFF0D4A3D),
                                      ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _MenuCourseRow extends StatelessWidget {
  const _MenuCourseRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -- Testimonios -------------------------------------------------------------

class _WebTestimonialsSection extends StatelessWidget {
  const _WebTestimonialsSection();

  static const _reviews = [
    (
      author: 'Maria G.',
      text:
          'La mejor comida casera de Sanlucar. El pollo asado es espectacular, '
          'igual que el de mi abuela. Llevo meses pidiendo cada semana.',
      rating: 5,
    ),
    (
      author: 'Carlos R.',
      text:
          'Pedimos catering para la comunion de mi hija y fue todo un exito. '
          'La organizacion perfecta y la comida deliciosa.',
      rating: 5,
    ),
    (
      author: 'Ana L.',
      text:
          'Los encargos son comodisimos. Dejo el pedido el dia anterior y lo '
          'recojo recien hecho. Sin colas, sin esperas.',
      rating: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                (_) =>
                    const Icon(Icons.star, color: Color(0xFFFFC107), size: 13),
              ),
              const SizedBox(width: 6),
              const Text(
                '4.9 · Valoraciones de clientes',
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
        const SizedBox(height: 10),
        Text(
          'LO QUE DICEN NUESTROS CLIENTES',
          style: GoogleFonts.bebasNeue(
            fontSize: 38,
            letterSpacing: 1.5,
            color: const Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (_, constraints) {
            const spacing = 20.0;
            final cols = constraints.maxWidth < 600 ? 1 : 3;
            final cardW = cols == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - spacing * (cols - 1)) / cols;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _reviews
                  .map(
                    (r) => SizedBox(
                      width: cardW,
                      child: _ReviewCard(review: r),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ({String author, String text, int rating}) review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"${review.text}"',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333330),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'â€” ${review.author}',
            style: const TextStyle(
              fontSize: 13,
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTokens.brandLight,
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1498837167922-ddd27525d352'
            '?q=80&w=1600&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
          opacity: 0.07,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 72),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    'MANTENTE AL DIA',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 42,
                      letterSpacing: 1.5,
                      color: AppTokens.brandDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Recibe el menu del dia y las ofertas especiales '
                    'directamente en tu correo o WhatsApp.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2D5E4F),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (status == SubscriptionStatus.done)
                    const _SubscribedMessage()
                  else
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _TypeToggle(
                                label: 'Email',
                                icon: Icons.email_outlined,
                                selected: !_isWhatsApp,
                                onTap: () => setState(() {
                                  _isWhatsApp = false;
                                  _ctrl.clear();
                                }),
                              ),
                              const SizedBox(width: 12),
                              _TypeToggle(
                                label: 'WhatsApp',
                                icon: Icons.phone_outlined,
                                selected: _isWhatsApp,
                                onTap: () => setState(() {
                                  _isWhatsApp = true;
                                  _ctrl.clear();
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _ctrl,
                            keyboardType: _isWhatsApp
                                ? TextInputType.phone
                                : TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: _isWhatsApp
                                  ? 'Tu numero de WhatsApp'
                                  : 'Tu correo electronico',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                _isWhatsApp
                                    ? Icons.phone_outlined
                                    : Icons.email_outlined,
                                color: AppTokens.brandPrimary,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return _isWhatsApp
                                    ? 'Introduce tu numero'
                                    : 'Introduce tu correo';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: status == SubscriptionStatus.loading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppTokens.brandPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: _subscribe,
                                    child: Text(
                                      'SUSCRIBIRME',
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 18,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                          ),
                          if (status == SubscriptionStatus.error) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Ha ocurrido un error. Intentalo de nuevo.',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
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

class _SubscribedMessage extends StatelessWidget {
  const _SubscribedMessage();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(
          Icons.check_circle_outline,
          color: AppTokens.brandPrimary,
          size: 48,
        ),
        SizedBox(height: 12),
        Text(
          'Te has suscrito con exito',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTokens.brandDark,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Pronto recibiras las novedades de Sabor de Casa.',
          style: TextStyle(fontSize: 14, color: Color(0xFF2D5E4F)),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTokens.brandPrimary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppTokens.brandPrimary
                : const Color(0xFFDDDDDD),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppTokens.brandPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppTokens.brandPrimary,
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

// ── Panel lateral del carrito (web) ─────────────────────────────────────────

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
                      style: GoogleFonts.bebasNeue(
                        fontSize: 22,
                        letterSpacing: 1.5,
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
  static const _cream = Color(0xFFF2EBD9);
  static const _muted = Color(0xFF8FBFB0);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top: logo + navegacion + redes
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 56, 48, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  children: [
                    // Logo izquierda
                    const SizedBox(
                      width: 240,
                      child: AppLogoText(
                        color: Colors.white,
                        fontSize: 50,
                      ),
                    ),

                    // Centro: nav + redes
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _FooterNavLink(
                                label: 'MENU',
                                onTap: () => context.goNamed(RouteNames.menu),
                              ),
                              const SizedBox(width: 36),
                              _FooterNavLink(
                                label: 'CATERING',
                                onTap: () =>
                                    context.goNamed(RouteNames.catering),
                              ),
                              const SizedBox(width: 36),
                              _FooterNavLink(
                                label: 'MIS PEDIDOS',
                                onTap: () =>
                                    context.goNamed(RouteNames.orders),
                              ),
                              const SizedBox(width: 36),
                              _FooterNavLink(
                                label: 'CONTACTO',
                                onTap: () =>
                                    context.goNamed(RouteNames.contact),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _FooterSocial(
                                icon: Icons.facebook,
                                tooltip: 'Facebook',
                              ),
                              SizedBox(width: 24),
                              _FooterSocial(
                                icon: Icons.camera_alt_outlined,
                                tooltip: 'Instagram',
                              ),
                              SizedBox(width: 24),
                              _FooterSocial(
                                icon: Icons.alternate_email,
                                tooltip: 'X / Twitter',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Espejo del logo (para centrar la columna central)
                    const SizedBox(width: 160),
                  ],
                ),
              ),
            ),
          ),

          // Nombre de marca gigante a todo ancho
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                'SABOR DE CASA',
                style: GoogleFonts.bebasNeue(
                  color: _cream,
                  letterSpacing: 6,
                  height: 0.85,
                ),
              ),
            ),
          ),

          // Legal + copyright
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 28, 48, 40),
            child: Column(
              children: [
                const Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 32,
                  runSpacing: 10,
                  children: [
                    _FooterLegalLink(label: 'Aviso legal'),
                    _FooterLegalLink(label: 'Privacidad'),
                    _FooterLegalLink(label: 'Cookies'),
                    _FooterLegalLink(label: 'Terminos y condiciones'),
                    _FooterLegalLink(label: 'Preguntas frecuentes'),
                    _FooterLegalLink(label: 'Contacto'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Copyright \u00a9 ${DateTime.now().year} Sabor de Casa. Todos los derechos reservados.',
                  style: const TextStyle(color: _muted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterNavLink extends StatelessWidget {
  const _FooterNavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}

class _FooterSocial extends StatelessWidget {
  const _FooterSocial({required this.icon, required this.tooltip});

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _FooterLegalLink extends StatelessWidget {
  const _FooterLegalLink({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Text(
        label,
        style: const TextStyle(
          color: _WebFooter._muted,
          fontSize: 13,
        ),
      ),
    );
  }
}

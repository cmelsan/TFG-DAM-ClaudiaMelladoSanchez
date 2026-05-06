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
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/menu_provider.dart';

class HomeScreenWeb extends ConsumerStatefulWidget {
  const HomeScreenWeb({super.key});

  @override
  ConsumerState<HomeScreenWeb> createState() => _HomeScreenWebState();
}

class _HomeScreenWebState extends ConsumerState<HomeScreenWeb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // â”€â”€ Navbar superior â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            const _WebNavbar(),

            // â”€â”€ Hero section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _WebHero(),
            // â”€â”€ Contenido centrado (max 1200px) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 56),

                      // Los mas pedidos del mes
                      _WebTopDishesSection(),

                      SizedBox(height: 56),

                      // Banner catering
                      _WebCateringBanner(),

                      SizedBox(height: 56),

                      // En oferta
                      _WebOffersSection(),

                      SizedBox(height: 56),

                      // Banner encargos
                      _WebEncargosBanner(),

                      SizedBox(height: 56),

                      // Platos de temporada
                      _WebSeasonalSection(),

                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),

            const LocationSection(),

            // ── Cómo funciona ────────────────────────────────────────────────
            const _WebHowItWorksSection(),

            // ── Footer ──────────────────────────────────────────────────────
            const _WebFooter(),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Navbar Web â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _WebNavbar extends ConsumerWidget {
  const _WebNavbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final cartCount = ref.watch(cartItemsCountProvider);
    final profile = authState.valueOrNull;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SizedBox(
            height: 90,
            child: Row(
              children: [
                // Logo
                GestureDetector(
                  onTap: () => context.goNamed(RouteNames.home),
                  child: Row(
                    children: [
                      const AppLogoText(
                        color: AppTokens.brandPrimary,
                        fontSize: 28,
                      ),
                      const SizedBox(width: 3),
                      Image.asset(
                        'assets/images/logo_bueno.png',
                        height: 250,
                        fit: BoxFit.contain,
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
                  icon: Badge.count(
                    count: cartCount,
                    isLabelVisible: cartCount > 0,
                    backgroundColor: Colors.red,
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF111111),
                    ),
                  ),
                  onPressed: () => context.goNamed(RouteNames.cart),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // Sobrescribe el tema global Size.fromHeight(56) que da
                      // ancho infinito y falla dentro de un Row.
                      minimumSize: const Size(0, 40),
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
                      minimumSize: const Size(0, 40),
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
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF111111),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }
}

// â”€â”€ Hero Web â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _WebHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final heroH = screenW < 480 ? 300.0 : screenW < 768 ? 420.0 : 580.0;
    final heroFont = screenW < 480 ? 46.0 : screenW < 768 ? 66.0 : 90.0;
    return SizedBox(
      width: double.infinity,
      height: heroH,
      child: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=1600&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          // Overlay verde oscuro estilo TGTG
          Positioned.fill(
            child: ColoredBox(
              color: const Color(0xFF0D3B2E).withValues(alpha: 0.84),
            ),
          ),
          // Contenido
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(
                      'LA COMIDA CASERA\nQUE TE MERECES',
                      style: GoogleFonts.bebasNeue(
                        fontSize: heroFont,
                        color: Colors.white,
                        letterSpacing: 2,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recogida, encargo o a domicilio.\nCocinado con amor en Sanlúcar de Barrameda.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        FilledButton(
                          onPressed: () => context.goNamed(RouteNames.menu),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0D3B2E),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 18,
                            ),
                            shape: const StadiumBorder(),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'VER EL MENÚ',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 18,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
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
                              horizontal: 36,
                              vertical: 18,
                            ),
                            shape: const StadiumBorder(),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'CATERING Y EVENTOS',
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
            ),
          ),
        ),
        ],
      ),
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
            TextButton(
              onPressed: () => context.goNamed(RouteNames.menu),
              child: const Text(
                'Ver todo →',
                style: TextStyle(
                  color: AppTokens.brandPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                    (i) => SizedBox(
                      width: cardW,
                      child: _TopDishCard(dish: top[i], rank: i + 1),
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
                      child: const Text(
                        'â­ Favorito',
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
                TextButton(
                  onPressed: () => context.goNamed(RouteNames.menu),
                  child: const Text(
                    'Ver todo â†’',
                    style: TextStyle(
                      color: AppTokens.brandPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                    (i) => SizedBox(
                      width: cardW,
                      child: _OfferDishCard(dish: offers[i]),
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
                      color: AppTokens.brandPrimary,
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
        if (seasonal.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      color: Color(0xFF5C9D3E),
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PLATOS DE TEMPORADA',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 38,
                        letterSpacing: 1.5,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.goNamed(RouteNames.menu),
                  child: const Text(
                    'Ver todo →',
                    style: TextStyle(
                      color: AppTokens.brandPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                    (i) => SizedBox(
                      width: cardW,
                      child: _SeasonalDishCard(dish: seasonal[i]),
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
      number: '01',
      title: 'ELIGE TUS PLATOS',
      body:
          'Explora el menú y elige entre decenas de recetas caseras. Filtra por categoría o busca por nombre.',
    ),
    (
      number: '02',
      title: 'COCINAMOS PARA TI',
      body:
          'Preparamos cada plato con ingredientes frescos y recetas de toda la vida, sin conservantes ni aditivos.',
    ),
    (
      number: '03',
      title: 'RECOGE O TE LO LLEVAMOS',
      body:
          'Pasa por el local con tu QR de recogida o pide que te lo llevemos a domicilio. Tú eliges.',
    ),
    (
      number: '04',
      title: '¡A DISFRUTAR!',
      body:
          'Comida de verdad lista en minutos. Solo sabor de casa en cada bocado.',
    ),
    (
      number: '05',
      title: 'CATERING Y EVENTOS',
      body:
          'Planifica tu celebración con nosotros. Comuniones, bodas, eventos de empresa — personalizamos cada menú.',
    ),
    (
      number: '06',
      title: 'ENCARGA CON ANTELACIÓN',
      body:
          'Reserva tus platos para el día que necesites. Sin esperas, con garantía de disponibilidad.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 72),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Cómo funciona?',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 42,
                      letterSpacing: 1,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 40),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth < 600
                          ? 1
                          : constraints.maxWidth < 900
                              ? 2
                              : 3;
                      const spacing = 20.0;
                      final cardWidth = cols == 1
                          ? constraints.maxWidth
                          : (constraints.maxWidth - spacing * (cols - 1)) /
                              cols;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: _steps
                            .map(
                              (s) => SizedBox(
                                width: cardWidth,
                                child: _HowItWorksCard(step: s),
                              ),
                            )
                            .toList(),
                      );
                    },
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
  const _HowItWorksCard({required this.step});

  final ({String number, String title, String body}) step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Número en círculo verde claro
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppTokens.brandLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.number,
                style: GoogleFonts.bebasNeue(
                  fontSize: 18,
                  letterSpacing: 1,
                  color: AppTokens.brandPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            step.title,
            style: GoogleFonts.bebasNeue(
              fontSize: 20,
              letterSpacing: 0.8,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            step.body,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555550),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

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
                      width: 160,
                      child: AppLogoText(
                        color: Colors.white,
                        fontSize: 22,
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

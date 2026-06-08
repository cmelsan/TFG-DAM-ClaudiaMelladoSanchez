import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/web_footer.dart';
import 'package:sabor_de_casa/core/widgets/web_navbar.dart';
import 'package:sabor_de_casa/features/catering/domain/models/event_menu.dart';
import 'package:sabor_de_casa/features/catering/presentation/providers/catering_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _heroImageUrl =
    'https://images.unsplash.com/photo-1514986888952-8cd320577b68'
  '?q=80&w=1600&fm=jpg&fit=crop';

// ─────────────────────────────────────────────────────────────────────────────
class CateringScreen extends ConsumerStatefulWidget {
  const CateringScreen({super.key});

  @override
  ConsumerState<CateringScreen> createState() => _CateringScreenState();
}

class _CateringScreenState extends ConsumerState<CateringScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heroFade;
  late final ScrollController _scrollCtrl;
  bool _isScrolled = false;

  bool get _isLoggedIn => Supabase.instance.client.auth.currentUser != null;

  @override
  void initState() {
    super.initState();
    _heroFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scrollCtrl = ScrollController()
      ..addListener(() {
        final scrolled = _scrollCtrl.offset > 10;
        if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
      });
  }

  @override
  void dispose() {
    _heroFade.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menusAsync = ref.watch(cateringMenusProvider);
    final screenW = MediaQuery.sizeOf(context).width;
    const maxW = 1200.0;
    final sidePad = screenW > maxW ? (screenW - maxW) / 2 : 0.0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: WebNavbar(
          isScrolled: _isScrolled,
          activeRoute: RouteNames.catering,
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollCtrl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero ────────────────────────────────────────────────
            _CateringHero(fadeCtrl: _heroFade, isLoggedIn: _isLoggedIn),

            // ── Sección "Nuestros menús de evento" ───────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(sidePad + 24, 48, sidePad + 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTokens.brandPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'MENÚS DE EVENTO',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTokens.brandPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Elige el menú perfecto',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF111111),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cada menú está diseñado para que tu evento sea único.\nSolicita tu presupuesto personalizado sin compromiso.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // ── Grid de menús ─────────────────────────────────────────
            menusAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTokens.brandPrimary,
                  ),
                ),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppTokens.danger,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error al cargar los menús',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.danger,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(cateringMenusProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (menus) => menus.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 60,
                        horizontal: 40,
                      ),
                      child: Center(
                        child: Text(
                          'Próximamente dispondremos de menús de eventos.\nContacta con nosotros para más información.',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(
                        sidePad + 16,
                        24,
                        sidePad + 16,
                        16,
                      ),
                      child: screenW > 760
                          ? _MenuGrid(menus: menus)
                          : _MenuList(menus: menus),
                    ),
            ),

            _PersonalizedMenuSection(sidePad: sidePad, isLoggedIn: _isLoggedIn),

            _LeadTimeSection(sidePad: sidePad),

            // ── CTA banner ────────────────────────────────────────────
            _CtaBanner(sidePad: sidePad, isLoggedIn: _isLoggedIn),

            // ── Cómo funciona ─────────────────────────────────────────
            _HowItWorksSection(sidePad: sidePad),

            const WebFooter(),
          ],
        ),
      ),
    );
  }
}

// ── Menu Grid / List helpers ──────────────────────────────────────────────────

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.menus});
  final List<EventMenu> menus;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: menus.map((menu) {
        return SizedBox(
          width:
              (MediaQuery.sizeOf(context).width -
                  (MediaQuery.sizeOf(context).width > 1200
                      ? (MediaQuery.sizeOf(context).width - 1200)
                      : 0) -
                  32 * 2 -
                  20) /
              2,
          height: 460,
          child: _MenuCard(menu: menu),
        );
      }).toList(),
    );
  }
}

class _MenuList extends StatelessWidget {
  const _MenuList({required this.menus});
  final List<EventMenu> menus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: menus
          .map(
            (menu) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(height: 460, child: _MenuCard(menu: menu)),
            ),
          )
          .toList(),
    );
  }
}

class _CateringHero extends StatelessWidget {
  const _CateringHero({required this.fadeCtrl, required this.isLoggedIn});

  final AnimationController fadeCtrl;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final heroH = screenW < 600 ? 620.0 : 520.0;
    final sidePad = screenW > 1200 ? (screenW - 1200) / 2 : 24.0;

    return FadeTransition(
      opacity: CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut),
      child: SizedBox(
        height: heroH,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo
            CachedNetworkImage(
              imageUrl: _heroImageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFF0D3B2E)),
            ),

            // Gradiente oscuro
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A2E20).withValues(alpha: 0.92),
                    const Color(0xFF0A2E20).withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),

            // Contenido
            Positioned(
              left: sidePad,
              right: sidePad,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(-0.1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: fadeCtrl,
                            curve: const Interval(
                              0,
                              0.6,
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTokens.brandPrimary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'CATERING CASERO',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Título
                  SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(-0.08, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: fadeCtrl,
                            curve: const Interval(
                              0.1,
                              0.7,
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                    child: Text(
                      'Celebraciones\ncon sabor de casa',
                      style: GoogleFonts.inter(
                        fontSize: screenW < 600 ? 34 : 54,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.05,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtítulo
                  SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(-0.06, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: fadeCtrl,
                            curve: const Interval(
                              0.2,
                              0.8,
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                    child: Text(
                      'Bodas, comuniones, cumpleaños y reuniones familiares\ncon menús preparados a medida por nuestro equipo.',
                      style: GoogleFonts.inter(
                        fontSize: screenW < 600 ? 14 : 16,
                        color: Colors.white.withValues(alpha: 0.80),
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Chips
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: fadeCtrl,
                      curve: const Interval(0.4, 1, curve: Curves.easeOut),
                    ),
                    child: const Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _HeroChip(
                          icon: Icons.people_outline,
                          label: 'Eventos pequeños y grandes',
                        ),
                        _HeroChip(
                          icon: Icons.restaurant_menu,
                          label: 'Menús a medida',
                        ),
                        _HeroChip(
                          icon: Icons.calendar_month_outlined,
                          label: 'Reserva con antelación',
                        ),
                        _HeroChip(
                          icon: Icons.room_service_outlined,
                          label: 'Prueba para bodas',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // CTA
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: fadeCtrl,
                      curve: const Interval(0.5, 1, curve: Curves.easeOut),
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            if (isLoggedIn) {
                              context.pushNamed(RouteNames.cateringRequest);
                            } else {
                              context.pushNamed(RouteNames.login);
                            }
                          },
                          icon: const Icon(
                            Icons.request_quote_outlined,
                            size: 18,
                          ),
                          label: Text(
                            'Concertar catering',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTokens.brandPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        if (isLoggedIn)
                          OutlinedButton.icon(
                            onPressed: () => context.pushNamed(
                              RouteNames.myCateringRequests,
                            ),
                            icon: const Icon(
                              Icons.list_alt_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Mis solicitudes',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                      ],
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

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu Card ─────────────────────────────────────────────────────────────────

class _MenuCard extends StatefulWidget {
  const _MenuCard({required this.menu});
  final EventMenu menu;

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? AppTokens.brandPrimary.withValues(alpha: 0.35)
                : const Color(0xFFE8E8E6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.10 : 0.04),
              blurRadius: _hovered ? 24 : 12,
              offset: Offset(0, _hovered ? 8 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen o placeholder
              SizedBox(
                height: 185,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (menu.imageUrl != null && menu.imageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: menu.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const _CardImagePlaceholder(),
                      )
                    else
                      const _CardImagePlaceholder(),

                    // Gradiente inferior
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Badge precio
                    Positioned(
                      top: 12,
                      left: 14,
                      child: _MenuBadge(
                        text:
                            menu.highlightLabel ??
                            _eventKindLabel(menu.eventKind),
                      ),
                    ),

                    if (menu.tastingAvailable)
                      const Positioned(
                        top: 12,
                        right: 14,
                        child: _MenuBadge(text: 'Prueba disponible'),
                      ),

                    // Badge precio
                    Positioned(
                      bottom: 10,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTokens.brandPrimary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${Formatters.price(menu.pricePerPerson)} / pax',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido inferior
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.name,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111111),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      if ((menu.description ?? '').isNotEmpty)
                        Text(
                          menu.description!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.42,
                          ),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const Spacer(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoPill(
                            icon: _eventKindIcon(menu.eventKind),
                            label: _eventKindLabel(menu.eventKind),
                          ),
                          _InfoPill(
                            icon: Icons.calendar_month_outlined,
                            label:
                                'Reserva ${menu.leadTimeMonths} ${menu.leadTimeMonths == 1 ? 'mes' : 'meses'} antes',
                          ),
                          if (menu.tastingAvailable)
                            const _InfoPill(
                              icon: Icons.room_service_outlined,
                              label: 'Prueba de menú',
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 15,
                            color: Colors.black45,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${menu.minGuests}–${menu.maxGuests} personas',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Mín. ${Formatters.price(menu.pricePerPerson * menu.minGuests)}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardImagePlaceholder extends StatelessWidget {
  const _CardImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTokens.brandPrimary.withValues(alpha: 0.07),
      child: const Center(
        child: Icon(
          Icons.dinner_dining_outlined,
          size: 48,
          color: AppTokens.brandPrimary,
        ),
      ),
    );
  }
}

class _MenuBadge extends StatelessWidget {
  const _MenuBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppTokens.brandDark,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppTokens.brandPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTokens.brandPrimary),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTokens.brandDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menú personalizado ───────────────────────────────────────────────────────

class _PersonalizedMenuSection extends StatelessWidget {
  const _PersonalizedMenuSection({
    required this.sidePad,
    required this.isLoggedIn,
  });

  final double sidePad;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;

    return Container(
      margin: EdgeInsets.fromLTRB(sidePad + 16, 28, sidePad + 16, 0),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E8E6)),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: screenW > 760
          ? Row(
              children: [
                const Expanded(child: _PersonalizedCopy()),
                const SizedBox(width: 28),
                _PersonalizedActions(isLoggedIn: isLoggedIn),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PersonalizedCopy(),
                const SizedBox(height: 20),
                _PersonalizedActions(isLoggedIn: isLoggedIn),
              ],
            ),
    );
  }
}

class _PersonalizedCopy extends StatelessWidget {
  const _PersonalizedCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menús personalizados para cada celebración',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF111111),
            height: 1.12,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Si ningún menú encaja exactamente, adaptamos la propuesta al evento que desee el cliente: número de invitados, presupuesto, alergias, platos favoritos, montaje y tiempos del servicio.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black54,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoPill(icon: Icons.tune_outlined, label: 'A medida'),
            _InfoPill(icon: Icons.no_food_outlined, label: 'Alergias'),
            _InfoPill(icon: Icons.groups_outlined, label: 'Invitados'),
            _InfoPill(icon: Icons.payments_outlined, label: 'Presupuesto'),
          ],
        ),
      ],
    );
  }
}

class _PersonalizedActions extends StatelessWidget {
  const _PersonalizedActions({required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: FilledButton.icon(
        onPressed: () {
          if (isLoggedIn) {
            context.pushNamed(RouteNames.cateringRequest);
          } else {
            context.pushNamed(RouteNames.login);
          }
        },
        icon: const Icon(Icons.edit_note_outlined, size: 18),
        label: Text(isLoggedIn ? 'Diseñar mi menú' : 'Iniciar sesión'),
        style: FilledButton.styleFrom(
          backgroundColor: AppTokens.brandPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ── Plazos de reserva ────────────────────────────────────────────────────────

class _LeadTimeSection extends StatelessWidget {
  const _LeadTimeSection({required this.sidePad});
  final double sidePad;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final cards = [
      const _LeadTimeCard(
        icon: Icons.cake_outlined,
        title: 'Cumpleaños y eventos pequeños',
        time: '1 mes',
        description:
            'Reservas para celebraciones familiares, reuniones privadas y eventos sencillos.',
      ),
      const _LeadTimeCard(
        icon: Icons.celebration_outlined,
        title: 'Comuniones y eventos grandes',
        time: '6 meses',
        description:
            'Necesitamos margen para ajustar invitados, montaje, menú infantil y detalles del servicio.',
      ),
      const _LeadTimeCard(
        icon: Icons.favorite_border,
        title: 'Bodas',
        time: '8 meses',
        description:
            'Incluye planificación completa y posibilidad de concertar prueba de menú.',
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(sidePad + 24, 56, sidePad + 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plazos para concertar catering',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF111111),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'El catering lo gestiona nuestro equipo administrador. El cliente envía la solicitud y nosotros confirmamos disponibilidad, presupuesto y cita si hace falta.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          if (screenW > 800)
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 16),
                Expanded(child: cards[1]),
                const SizedBox(width: 16),
                Expanded(child: cards[2]),
              ],
            )
          else
            Column(
              children: [
                cards[0],
                const SizedBox(height: 14),
                cards[1],
                const SizedBox(height: 14),
                cards[2],
              ],
            ),
        ],
      ),
    );
  }
}

class _LeadTimeCard extends StatelessWidget {
  const _LeadTimeCard({
    required this.icon,
    required this.title,
    required this.time,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String time;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTokens.brandPrimary, size: 26),
          const SizedBox(height: 14),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppTokens.brandPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black54,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// ── CTA Banner ────────────────────────────────────────────────────────────────

class _CtaBanner extends StatelessWidget {
  const _CtaBanner({required this.sidePad, required this.isLoggedIn});

  final double sidePad;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;

    return Container(
      margin: EdgeInsets.fromLTRB(sidePad + 16, 32, sidePad + 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTokens.brandDark, Color(0xFF0A4A39)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandPrimary.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Círculos decorativos
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(32, 36, 32, 36),
              child: screenW > 700
                  ? Row(
                      children: [
                        Expanded(child: _CtaContent(isLoggedIn: isLoggedIn)),
                        const SizedBox(width: 32),
                        IntrinsicWidth(
                          child: _CtaButtons(isLoggedIn: isLoggedIn),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CtaContent(isLoggedIn: isLoggedIn),
                        const SizedBox(height: 24),
                        _CtaButtons(isLoggedIn: isLoggedIn),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CtaContent extends StatelessWidget {
  const _CtaContent({required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Tienes un evento en mente?',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isLoggedIn
              ? 'Cuéntanos los detalles y te enviamos un presupuesto sin compromiso en menos de 24 h.'
              : 'Inicia sesión para solicitar tu presupuesto personalizado. Es rápido y sin compromiso.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.75),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _CtaButtons extends StatelessWidget {
  const _CtaButtons({required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () {
            if (isLoggedIn) {
              context.pushNamed(RouteNames.cateringRequest);
            } else {
              context.pushNamed(RouteNames.login);
            }
          },
          icon: const Icon(Icons.request_quote_outlined, size: 18),
          label: Text(
            isLoggedIn ? 'Solicitar presupuesto' : 'Iniciar sesión',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTokens.brandDark,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (isLoggedIn) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.pushNamed(RouteNames.myCateringRequests),
            icon: const Icon(
              Icons.list_alt_outlined,
              size: 16,
              color: Colors.white,
            ),
            label: Text(
              'Ver mis solicitudes',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Cómo funciona ─────────────────────────────────────────────────────────────

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection({required this.sidePad});
  final double sidePad;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: EdgeInsets.fromLTRB(sidePad + 24, 56, sidePad + 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTokens.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'CÓMO FUNCIONA',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppTokens.brandPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tres pasos, sin complicaciones',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111111),
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Organizamos tu evento con la máxima sencillez.',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          if (screenW > 700)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StepCard(
                    step: '01',
                    icon: Icons.restaurant_menu_outlined,
                    title: 'Elige tu menú',
                    description:
                        'Selecciona el menú que mejor encaje con tu evento y el número de invitados.',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _StepCard(
                    step: '02',
                    icon: Icons.edit_note_outlined,
                    title: 'Cuéntanos los detalles',
                    description:
                        'Indícanos la fecha, lugar y cualquier necesidad especial de tu celebración.',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _StepCard(
                    step: '03',
                    icon: Icons.celebration_outlined,
                    title: 'Disfruta del evento',
                    description:
                        'Recibe tu presupuesto en menos de 24 h y deja que nosotros nos ocupemos de todo.',
                  ),
                ),
              ],
            )
          else
            const Column(
              children: [
                _StepCard(
                  step: '01',
                  icon: Icons.restaurant_menu_outlined,
                  title: 'Elige tu menú',
                  description:
                      'Selecciona el menú que mejor encaje con tu evento y el número de invitados.',
                ),
                SizedBox(height: 16),
                _StepCard(
                  step: '02',
                  icon: Icons.edit_note_outlined,
                  title: 'Cuéntanos los detalles',
                  description:
                      'Indícanos la fecha, lugar y cualquier necesidad especial de tu celebración.',
                ),
                SizedBox(height: 16),
                _StepCard(
                  step: '03',
                  icon: Icons.celebration_outlined,
                  title: 'Disfruta del evento',
                  description:
                      'Recibe tu presupuesto en menos de 24 h y deja que nosotros nos ocupemos de todo.',
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String step;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTokens.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: AppTokens.brandPrimary),
              ),
              const Spacer(),
              Text(
                step,
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppTokens.brandPrimary.withValues(alpha: 0.12),
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

String _eventKindLabel(String eventKind) {
  switch (eventKind) {
    case 'wedding':
      return 'Bodas';
    case 'communion':
      return 'Comuniones';
    case 'business':
      return 'Empresa';
    case 'family':
      return 'Familiar';
    case 'custom':
      return 'A medida';
    case 'small':
    default:
      return 'Evento pequeño';
  }
}

IconData _eventKindIcon(String eventKind) {
  switch (eventKind) {
    case 'wedding':
      return Icons.favorite_border;
    case 'communion':
      return Icons.celebration_outlined;
    case 'business':
      return Icons.business_center_outlined;
    case 'family':
      return Icons.groups_outlined;
    case 'custom':
      return Icons.tune_outlined;
    case 'small':
    default:
      return Icons.cake_outlined;
  }
}

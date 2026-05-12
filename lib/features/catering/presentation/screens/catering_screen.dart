import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/catering/domain/models/event_menu.dart';
import 'package:sabor_de_casa/features/catering/presentation/providers/catering_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CateringScreen extends ConsumerWidget {
  const CateringScreen({super.key});

  bool get _isLoggedIn =>
      Supabase.instance.client.auth.currentUser != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menusAsync = ref.watch(cateringMenusProvider);
    final screenW = MediaQuery.sizeOf(context).width;
    final sidePad = screenW > 1200 ? (screenW - 1200) / 2 : 0.0;

    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      body: menusAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(cateringMenusProvider),
        ),
        data: (menus) => CustomScrollView(
          slivers: [
            // ── Hero banner ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _HeroBanner(isLoggedIn: _isLoggedIn)),

            // ── Encabezado sección menús ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    sidePad + 24, 40, sidePad + 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nuestros menús de evento',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Elige el menú que mejor encaje con tu celebración y solicita tu presupuesto personalizado.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Lista de menús ─────────────────────────────────────────────
            if (menus.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'Próximamente dispondremos de menús de eventos.\nContacta con nosotros para más información.',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    sidePad + 16, 16, sidePad + 16, 100),
                sliver: screenW > 700
                    ? SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _MenuCard(menu: menus[i]),
                          childCount: menus.length,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _MenuCard(menu: menus[i]),
                          ),
                          childCount: menus.length,
                        ),
                      ),
              ),
          ],
        ),
      ),

      // ── Barra de acciones inferior ────────────────────────────────────────
      bottomNavigationBar: _BottomActions(isLoggedIn: _isLoggedIn),
    );
  }
}

// ─────────────────────────────────────────── Hero Banner ───────────────────────
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTokens.brandDark, Color(0xFF0A4A39)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back / nav context
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.celebration_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Eventos & Catering',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Headline
              Text(
                'Haz tu evento\ninolvidable',
                style: GoogleFonts.inter(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Cumpleaños, bodas, reuniones de empresa o\ncualquier celebración. Nosotros ponemos el\nsabor casero, tú pones los invitados.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),

              // Chips de características
              const Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeroChip(icon: Icons.people_outline, label: 'Desde 10 personas'),
                  _HeroChip(icon: Icons.restaurant_menu, label: 'Menús a medida'),
                  _HeroChip(icon: Icons.euro_outlined, label: 'Presupuesto sin coste'),
                  _HeroChip(icon: Icons.location_on_outlined, label: 'En tu espacio'),
                ],
              ),
            ],
          ),
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
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
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

// ─────────────────────────────────────────── Menu Card ─────────────────────────
class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.menu});
  final EventMenu menu;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono con color
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTokens.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.dinner_dining,
                    color: AppTokens.brandPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.name,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111111),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Badge precio
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTokens.brandPrimary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${Formatters.price(menu.pricePerPerson)} / pax',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if ((menu.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                menu.description!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const Spacer(),
            const Divider(height: 24, color: Color(0xFFF0F0EE)),

            // Fila de datos
            Row(
              children: [
                const Icon(Icons.people_outline,
                    size: 16, color: Colors.black45),
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
                    fontSize: 13,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────── Bottom Actions ────────────────────
class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              if (isLoggedIn) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.pushNamed(RouteNames.myCateringRequests),
                    icon: const Icon(Icons.list_alt_outlined, size: 18),
                    label: const Text('Mis solicitudes'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTokens.brandPrimary,
                      side: const BorderSide(color: AppTokens.brandPrimary),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    if (isLoggedIn) {
                      context.pushNamed(RouteNames.cateringRequest);
                    } else {
                      context.pushNamed(RouteNames.login);
                    }
                  },
                  icon: const Icon(Icons.request_quote_outlined, size: 18),
                  label: Text(
                    isLoggedIn
                        ? 'Solicitar catering'
                        : 'Inicia sesión para solicitar',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTokens.brandPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/catering/presentation/providers/catering_provider.dart';

class CateringScreen extends ConsumerWidget {
  const CateringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menusAsync = ref.watch(cateringMenusProvider);

    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      appBar: AppBar(
        title: const Text('Eventos y Catering'),
        centerTitle: true,
      ),
      body: menusAsync.when(
        data: (menus) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE5E5E3)),
                        ),
                        child: const Icon(
                          Icons.celebration_outlined,
                          size: 64,
                          color: AppTokens.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'HAZ TU EVENTO INOLVIDABLE',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 30,
                          letterSpacing: 1.5,
                          color: const Color(0xFF111111),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Cumpleaños, reuniones de empresa o celebraciones. Nosotros ponemos el sabor casero y tú pones los invitados.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              if (menus.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Actualmente no hay menús de eventos disponibles.',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final menu = menus[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E5E3)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        menu.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Color(0xFF111111),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${Formatters.price(menu.pricePerPerson)}/pax',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppTokens.brandPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                if ((menu.description ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    menu.description!,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTokens.pageBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.people_outline,
                                        size: 18,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'De ${menu.minGuests} a ${menu.maxGuests} invitados',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
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
                    }, childCount: menus.length),
                  ),
                ),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(cateringMenusProvider),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E5E3))),
        ),
        child: SafeArea(
          child: FilledButton.icon(
            onPressed: () => context.pushNamed(RouteNames.login),
            icon: const Icon(Icons.request_quote_outlined),
            label: const Text(
              'Solicitar presupuesto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}

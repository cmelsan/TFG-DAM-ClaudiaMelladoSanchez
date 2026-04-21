import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
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
      appBar: AppBar(title: const Text('Catering')),
      body: menusAsync.when(
        data: (menus) {
          if (menus.isEmpty) {
            return const Center(
              child: Text('No hay menús de eventos activos'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: menus.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final menu = menus[index];
              return Card(
                child: ListTile(
                  title: Text(menu.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((menu.description ?? '').isNotEmpty)
                        Text(menu.description!),
                      const SizedBox(height: 4),
                      Text(
                        'Precio por persona: '
                        '${Formatters.price(menu.pricePerPerson)}',
                      ),
                      Text('Invitados: ${menu.minGuests} - ${menu.maxGuests}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(cateringMenusProvider),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: FilledButton.icon(
          onPressed: () => context.pushNamed(RouteNames.login),
          icon: const Icon(Icons.request_quote_outlined),
          label: const Text('Solicitar presupuesto (login requerido)'),
        ),
      ),
    );
  }
}

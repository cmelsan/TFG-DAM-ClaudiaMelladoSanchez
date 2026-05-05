import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';

class AdminConfigScreen extends ConsumerWidget {
  const AdminConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(adminConfigProvider);

    return AdminShell(
      title: 'Configuración',
      child: configAsync.when(
        data: (items) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (_, index) {
            final item = items[index];
            final isBoolKey = item.value == 'true' || item.value == 'false';
            return Card(
              child: isBoolKey
                  ? SwitchListTile(
                      title: Text(_keyLabel(item.key)),
                      subtitle: Text(item.key),
                      value: item.value == 'true',
                      onChanged: (v) {
                        ref
                            .read(adminActionProvider.notifier)
                            .updateConfig(
                              id: item.id,
                              value: v.toString(),
                            );
                      },
                    )
                  : ListTile(
                      title: Text(_keyLabel(item.key)),
                      subtitle: Text(item.value),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            _showEditDialog(context, ref, item.id, item.value),
                      ),
                    ),
            );
          },
        ),
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminConfigProvider),
        ),
      ),
    );
  }

  String _keyLabel(String key) {
    const labels = <String, String>{
      'business_name': 'Nombre del negocio',
      'phone': 'Teléfono',
      'email': 'Correo electrónico',
      'address': 'Dirección',
      'delivery_fee': 'Coste de envío (€)',
      'min_order_delivery': 'Pedido mínimo envío (€)',
      'max_delivery_km': 'Distancia máx. reparto (km)',
      'currency': 'Moneda',
      'encargo_min_days_advance': 'Días mín. antelación encargos',
      'show_offers_section': 'Mostrar sección "En oferta" en la home',
      'show_seasonal_section': 'Mostrar sección "Platos de temporada" en la home',
    };
    return labels[key] ?? key;
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    String currentValue,
  ) async {
    final ctrl = TextEditingController(text: currentValue);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar valor'),
          content: TextField(controller: ctrl),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                ref
                    .read(adminActionProvider.notifier)
                    .updateConfig(id: id, value: ctrl.text);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

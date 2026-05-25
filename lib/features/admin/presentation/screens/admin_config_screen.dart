import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/features/admin/domain/models/business_config_item.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';

const _keyLabels = <String, String>{
  'business_name': 'Nombre del negocio',
  'phone': 'Teléfono',
  'email': 'Correo electrónico',
  'address': 'Dirección',
  'delivery_fee': 'Coste de envío (€)',
  'min_order_delivery': 'Pedido mínimo envío (€)',
  'max_delivery_km': 'Distancia máx. reparto (km)',
  'currency': 'Moneda',
  'encargo_min_days_advance': 'Días mín. antelación encargos',
  'show_offers_section': 'Mostrar sección "En oferta"',
  'show_seasonal_section': 'Mostrar sección "Temporada"',
  'first_order_discount_enabled': 'Descuento 30% primer pedido',
};

class AdminConfigScreen extends ConsumerWidget {
  const AdminConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(adminConfigProvider);

    return AdminShell(
      title: 'Configuración',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTokens.brandPrimary),
          tooltip: 'Actualizar',
          onPressed: () => ref.invalidate(adminConfigProvider),
        ),
        const SizedBox(width: 8),
      ],
      child: configAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(
          child: ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(adminConfigProvider),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                'Sin configuración disponible',
                style: GoogleFonts.inter(color: const Color(0xFF9E9E9E)),
              ),
            );
          }
          // Agrupa booleanos y valores de texto por separado visualmente
          final boolItems = items.where(
              (i) => i.value == 'true' || i.value == 'false').toList();
          final textItems = items.where(
              (i) => i.value != 'true' && i.value != 'false').toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              if (textItems.isNotEmpty) ...[
                const SectionHeader('Ajustes generales'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: [AppTokens.cardShadow],
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < textItems.length; i++) ...[
                        if (i > 0)
                          Container(height: 1, color: const Color(0xFFF0F0F0)),
                        _TextConfigRow(
                          item: textItems[i],
                          onEdit: () => _showEditDialog(
                              context, ref, textItems[i].id, textItems[i].value),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (boolItems.isNotEmpty) ...[
                const SectionHeader('Visibilidad y funciones'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: [AppTokens.cardShadow],
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < boolItems.length; i++) ...[
                        if (i > 0)
                          Container(height: 1, color: const Color(0xFFF0F0F0)),
                        _BoolConfigRow(item: boolItems[i], ref: ref),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
        title: Text('Editar valor',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: GoogleFonts.inter()),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: AppTokens.brandPrimary),
            onPressed: () {
              ref.read(adminActionProvider.notifier).updateConfig(
                    id: id,
                    value: ctrl.text.trim(),
                  );
              Navigator.pop(ctx);
            },
            child: Text('Guardar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Fila de texto ─────────────────────────────────────────────────────────────

class _TextConfigRow extends StatelessWidget {
  const _TextConfigRow({required this.item, required this.onEdit});
  final BusinessConfigItem item;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _keyLabels[item.key] ?? item.key,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF8A8FA8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppTokens.brandPrimary, size: 18),
            tooltip: 'Editar',
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

// ── Fila de booleano ──────────────────────────────────────────────────────────

class _BoolConfigRow extends StatelessWidget {
  const _BoolConfigRow({required this.item, required this.ref});
  final BusinessConfigItem item;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isOn = item.value == 'true';
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        _keyLabels[item.key] ?? item.key,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
      ),
      value: isOn,
      activeColor: AppTokens.brandPrimary,
      onChanged: (v) => ref
          .read(adminActionProvider.notifier)
          .updateConfig(id: item.id, value: v.toString()),
    );
  }
}

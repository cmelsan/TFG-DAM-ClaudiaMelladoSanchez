import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';

class AdminEncargosScreen extends ConsumerWidget {
  const AdminEncargosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final encargosAsync = ref.watch(adminEncargosProvider);
    final minDaysAsync = ref.watch(encargoMinDaysProvider);

    return AdminShell(
      title: 'Encargos',
      child: Column(
        children: [
          // Banner de configuración de días mínimos
          minDaysAsync
                  .whenData(
                    (days) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTokens.brandPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTokens.brandPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppTokens.brandPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Antelación mínima actual: $days ${days == 1 ? 'día' : 'días'}. '
                              'Configurable en Ajustes → Configuración.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTokens.brandPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .value ??
              const SizedBox.shrink(),

          Expanded(
            child: encargosAsync.when(
              data: (encargos) {
                if (encargos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 72,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay encargos pendientes',
                          style: TextStyle(color: Colors.black54, fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                // Separar pendientes (necesitan aprobación) de confirmados/en preparación/listos
                final pending = encargos
                    .where((o) => o.status == 'pending')
                    .toList();
                final inProgress = encargos
                    .where((o) => o.status != 'pending')
                    .toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (pending.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Pendientes de aprobación',
                        count: pending.length,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(height: 8),
                      ...pending.map(
                        (o) => _EncargoCard(order: o, showActions: true),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (inProgress.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Aprobados / En preparación',
                        count: inProgress.length,
                        color: AppTokens.brandPrimary,
                      ),
                      const SizedBox(height: 8),
                      ...inProgress.map(
                        (o) => _EncargoCard(order: o, showActions: false),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(adminEncargosProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _EncargoCard extends ConsumerWidget {
  const _EncargoCard({required this.order, required this.showActions});

  final Order order;
  final bool showActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledDate = order.scheduledAt;
    final daysUntil = scheduledDate?.difference(DateTime.now()).inDays;
    final isUrgent = daysUntil != null && daysUntil <= 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent ? Colors.orange.shade300 : const Color(0xFFE5E5E3),
          width: isUrgent ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUrgent ? Colors.orange.shade50 : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Text(
                  '#${order.id.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(width: 12),
                _StatusChip(status: order.status),
                const Spacer(),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'URGENTE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha programada
                if (scheduledDate != null)
                  Row(
                    children: [
                      const Icon(Icons.event, size: 18, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text(
                        'Para el ${Formatters.date(scheduledDate)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (daysUntil != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          daysUntil == 0
                              ? '(Hoy)'
                              : daysUntil == 1
                              ? '(Mañana)'
                              : '(en $daysUntil días)',
                          style: TextStyle(
                            color: isUrgent
                                ? Colors.orange.shade700
                                : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.euro, size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      'Total: ${Formatters.price(order.total)}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),

                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notes, size: 18, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.notes!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Badge estado del pago
                const SizedBox(height: 8),
                _PaymentStatusBadge(order: order),
              ],
            ),
          ),

          // Botones de acción (solo para pendientes de aprobación)
          if (showActions)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _reject(context, ref),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Rechazar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _accept(context, ref),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Aceptar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTokens.brandPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Botón Cobrar: encargo listo + pago pendiente en tienda
          if (!showActions &&
              order.status == 'ready' &&
              order.paymentStatus == 'pending' &&
              (order.paymentMethod == 'cash' || order.paymentMethod == 'tpv'))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _cobrar(context, ref),
                  icon: const Icon(Icons.payments_outlined),
                  label: Text(
                    order.paymentMethod == 'tpv'
                        ? 'Confirmar pago con TPV'
                        : 'Confirmar cobro en efectivo',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _accept(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aceptar encargo'),
        content: Text(
          '¿Confirmar el encargo #${order.id.substring(0, 6).toUpperCase()} '
          'y enviarlo a cocina?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminActionProvider.notifier).acceptEncargo(order.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTokens.brandPrimary,
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _reject(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rechazar encargo'),
        content: Text(
          '¿Rechazar el encargo #${order.id.substring(0, 6).toUpperCase()}? '
          'El cliente será notificado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminActionProvider.notifier).rejectEncargo(order.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  void _cobrar(BuildContext context, WidgetRef ref) {
    final metodoPago = order.paymentMethod == 'tpv'
        ? 'TPV (tarjeta en tienda)'
        : 'efectivo';
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar cobro'),
        content: Text(
          '¿Confirmas que el cliente ha recogido el encargo '
          '#${order.id.substring(0, 6).toUpperCase()} y ha pagado '
          '${Formatters.price(order.total)} en $metodoPago?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Marca entregado + cobrado en una sola llamada
              ref
                  .read(adminActionProvider.notifier)
                  .markDeliveredAndPaid(order.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
            ),
            child: const Text('Sí, cobrado'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'pending' => ('Pendiente', Colors.orange),
      'confirmed' => ('Confirmado', AppTokens.brandPrimary),
      'preparing' => ('Preparando', Colors.blue.shade700),
      'ready' => ('Listo', Colors.green.shade700),
      'cancelled' => ('Cancelado', Colors.red),
      _ => (status, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    if (order.paymentStatus == 'paid') {
      return _badge(
        Icons.check_circle_outline,
        'Pagado',
        Colors.green.shade700,
      );
    }
    return switch (order.paymentMethod) {
      'cash' => _badge(
        Icons.money,
        'Pendiente: efectivo en local',
        Colors.orange.shade700,
      ),
      'tpv' => _badge(
        Icons.point_of_sale,
        'Pendiente: TPV en local',
        Colors.orange.shade700,
      ),
      'card' => _badge(
        Icons.credit_card,
        'Pendiente: pago online',
        Colors.blue.shade700,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

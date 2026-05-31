import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order_extensions.dart';

// ── Paleta local ──────────────────────────────────────────────────────────────
const _kTextPrimary   = Color(0xFF1B4332);
const _kTextSecondary = Color(0xFF2D6A4F);
const _kTextMuted     = Color(0xFF6BAF8A);
const _kBorderColor   = Color(0xFFB7DFC9);
const _kItemBg        = Color(0xFFF8FDF9);
const _kDivider       = Color(0xFFE2F2E9);

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
          // Banner días mínimos de antelación
          minDaysAsync
                  .whenData(
                    (days) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTokens.brandPrimary.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusMd),
                        border: Border.all(
                            color: AppTokens.brandPrimary
                                .withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: AppTokens.brandPrimary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Antelación mínima actual: $days ${days == 1 ? "día" : "días"}. '
                              'Configurable en Ajustes → Configuración.',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: _kTextSecondary),
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
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: AppTokens.brandLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 40,
                            color: AppTokens.brandPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay encargos pendientes',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: _kTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Los nuevos encargos aparecerán aquí',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: _kTextMuted),
                        ),
                      ],
                    ),
                  );
                }

                final pending =
                    encargos.where((o) => o.status == 'pending').toList();
                final inProgress =
                    encargos.where((o) => o.status != 'pending').toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  children: [
                    if (pending.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Pendientes de aprobación',
                        count: pending.length,
                        color: AppTokens.warning,
                      ),
                      const SizedBox(height: 10),
                      ...pending.map(
                          (o) => _EncargoCard(order: o, showActions: true)),
                      const SizedBox(height: 24),
                    ],
                    if (inProgress.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Aprobados / En preparación',
                        count: inProgress.length,
                        color: AppTokens.brandPrimary,
                      ),
                      const SizedBox(height: 10),
                      ...inProgress.map(
                          (o) => _EncargoCard(order: o, showActions: false)),
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

// ── Cabecera de sección ───────────────────────────────────────────────────────

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
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: color == AppTokens.brandPrimary ? _kTextPrimary : color,
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
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tarjeta de encargo ────────────────────────────────────────────────────────

class _EncargoCard extends ConsumerWidget {
  const _EncargoCard({required this.order, required this.showActions});

  final Order order;
  final bool showActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledDate = order.scheduledAt;
    final daysUntil = scheduledDate?.difference(DateTime.now()).inDays;
    final isUrgent = daysUntil != null && daysUntil <= 1;

    // Color de la barra lateral según estado
    final barColor = switch (order.status) {
      'pending'   => AppTokens.warning,
      'confirmed' => AppTokens.brandPrimary,
      'preparing' => AppTokens.info,
      'ready'     => AppTokens.success,
      'cancelled' => AppTokens.danger,
      _           => _kBorderColor,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: isUrgent
              ? AppTokens.warning.withValues(alpha: 0.5)
              : _kBorderColor,
          width: isUrgent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandPrimary.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra lateral de estado
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppTokens.radiusLg)),
              ),
            ),
            // Contenido principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Cabecera ──────────────────────────────────────────
                    Row(
                      children: [
                        Text(
                          '#${order.shortId}',
                          style: GoogleFonts.jetBrainsMono(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: _kTextPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _StatusChip(status: order.status),
                        const Spacer(),
                        if (isUrgent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTokens.warning,
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radiusSm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'URGENTE',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1, color: _kDivider),
                    const SizedBox(height: 12),

                    // ── Fecha programada ──────────────────────────────────
                    if (scheduledDate != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.event_rounded,
                              size: 15, color: _kTextMuted),
                          const SizedBox(width: 8),
                          Text(
                            'Para el ${Formatters.date(scheduledDate)}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: _kTextPrimary,
                            ),
                          ),
                          if (daysUntil != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isUrgent
                                    ? AppTokens.warning
                                        .withValues(alpha: 0.12)
                                    : AppTokens.brandLight,
                                borderRadius: BorderRadius.circular(
                                    AppTokens.radiusSm),
                              ),
                              child: Text(
                                daysUntil == 0
                                    ? 'Hoy'
                                    : daysUntil == 1
                                        ? 'Mañana'
                                        : 'en $daysUntil días',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isUrgent
                                      ? AppTokens.warning
                                      : _kTextSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],

                    // ── Total ─────────────────────────────────────────────
                    Row(
                      children: [
                        const Icon(Icons.euro_rounded,
                            size: 15, color: _kTextMuted),
                        const SizedBox(width: 8),
                        Text(
                          'Total: ',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: _kTextSecondary),
                        ),
                        Text(
                          Formatters.price(order.total),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTokens.brandDark,
                          ),
                        ),
                      ],
                    ),

                    // ── Notas ─────────────────────────────────────────────
                    if (order.notes != null && order.notes!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _kItemBg,
                          border: Border.all(color: _kBorderColor),
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusSm),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.notes_rounded,
                                size: 14, color: _kTextMuted),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.notes!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: _kTextSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── Estado del pago ───────────────────────────────────
                    const SizedBox(height: 10),
                    _PaymentStatusBadge(order: order),

                    // ── Botones acción (pendientes de aprobación) ─────────
                    if (showActions) ...[
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: _kDivider),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _reject(context, ref),
                              icon: const Icon(Icons.close_rounded, size: 16),
                              label: Text('Rechazar',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTokens.danger,
                                side: const BorderSide(
                                    color: AppTokens.danger),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppTokens.radiusMd)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _accept(context, ref),
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: Text('Aceptar',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTokens.brandPrimary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppTokens.radiusMd)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // ── Indicador: gestión en mostrador ──────────────────
                    if (!showActions && order.status == 'ready') ...[
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: _kDivider),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTokens.success.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusMd),
                          border: Border.all(
                              color:
                                  AppTokens.success.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.storefront_outlined,
                                size: 15, color: AppTokens.success),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Listo para recoger · Cobro y entrega en Mostrador',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTokens.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.04, end: 0);
  }

  void _accept(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Aceptar encargo',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          '¿Confirmar el encargo #${order.shortId} '
          'y enviarlo a cocina?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: _kTextMuted)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminActionProvider.notifier).acceptEncargo(order.id);
            },
            style: FilledButton.styleFrom(
                backgroundColor: AppTokens.brandPrimary),
            child: Text('Aceptar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _reject(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Rechazar encargo',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          '¿Rechazar el encargo #${order.shortId}? '
          'El cliente será notificado.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: _kTextMuted)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminActionProvider.notifier).rejectEncargo(order.id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTokens.danger),
            child: Text('Rechazar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

}

// ── Chip de estado ────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'pending'   => ('Pendiente',  AppTokens.warning),
      'confirmed' => ('Confirmado', AppTokens.brandPrimary),
      'preparing' => ('Preparando', AppTokens.info),
      'ready'     => ('Listo',      AppTokens.success),
      'cancelled' => ('Cancelado',  AppTokens.danger),
      _           => (status,       _kTextMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Badge de estado de pago ───────────────────────────────────────────────────

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    if (order.paymentStatus == 'paid') {
      return _badge(
          Icons.check_circle_outline_rounded, 'Pagado', AppTokens.success);
    }
    return switch (order.paymentMethod) {
      'cash' => _badge(Icons.money_rounded, 'Pendiente: efectivo en local',
          AppTokens.warning),
      'tpv'  => _badge(Icons.point_of_sale_rounded,
          'Pendiente: TPV en local', AppTokens.warning),
      'card' => _badge(Icons.credit_card_rounded, 'Pendiente: pago online',
          AppTokens.info),
      _      => const SizedBox.shrink(),
    };
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

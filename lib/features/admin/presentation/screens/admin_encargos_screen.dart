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

// ─── Tokens visuales compartidos (estilo dashboard/stats) ───────────────────
const _kPageBg = Color(0xFFF4F6F8);
const _kCardBorder = Color(0xFFEEEEEE);
const _kInk = Color(0xFF1A1A2E);
const _kInkMuted = Color(0xFF6B7280);
const _kInkSoft = Color(0xFF9CA3AF);

const _statusLabels = {
  'pending': 'Pendiente',
  'confirmed': 'Confirmado',
  'preparing': 'Preparando',
  'ready': 'Listo',
  'cancelled': 'Cancelado',
};

Color _statusColor(String status) => switch (status) {
      'pending' => AppTokens.warning,
      'confirmed' => AppTokens.brandPrimary,
      'preparing' => AppTokens.info,
      'ready' => AppTokens.success,
      'cancelled' => AppTokens.danger,
      _ => _kInkSoft,
    };

// ── Pantalla principal ───────────────────────────────────────────────────────

class AdminEncargosScreen extends ConsumerStatefulWidget {
  const AdminEncargosScreen({super.key});

  @override
  ConsumerState<AdminEncargosScreen> createState() =>
      _AdminEncargosScreenState();
}

class _AdminEncargosScreenState extends ConsumerState<AdminEncargosScreen> {
  String _statusFilter = 'all';
  String _search = '';

  void _refresh() {
    ref.invalidate(adminEncargosProvider);
  }

  @override
  Widget build(BuildContext context) {
    final encargosAsync = ref.watch(adminEncargosProvider);
    final minDaysAsync = ref.watch(encargoMinDaysProvider);

    return AdminShell(
      title: 'Encargos',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: AppTokens.brandPrimary),
          tooltip: 'Actualizar',
          onPressed: _refresh,
        ),
        const SizedBox(width: 8),
      ],
      child: ColoredBox(
        color: _kPageBg,
        child: encargosAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => Center(
            child: ErrorView(
              message: e.toString(),
              onRetry: _refresh,
            ),
          ),
          data: (encargos) {
            final pending =
                encargos.where((o) => o.status == 'pending').toList();
            final inProgress =
                encargos.where((o) => o.status != 'pending').toList();

            final filtered = encargos.where((o) {
              if (_statusFilter != 'all' && o.status != _statusFilter) {
                return false;
              }
              if (_search.isNotEmpty) {
                final hay = '${o.shortId} ${o.notes ?? ''}'.toLowerCase();
                if (!hay.contains(_search)) return false;
              }
              return true;
            }).toList();

            final filteredPending =
                filtered.where((o) => o.status == 'pending').toList();
            final filteredOthers =
                filtered.where((o) => o.status != 'pending').toList();

            return CustomScrollView(
              slivers: [
                // ── KPI strip ──────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: _EncargosKpiStrip(
                      total: encargos.length,
                      pending: pending.length,
                      inProgress: inProgress.length,
                      urgent: encargos.where((o) {
                        final d = o.scheduledAt;
                        if (d == null) return false;
                        final diff = d.difference(DateTime.now()).inDays;
                        return diff <= 1 && o.status != 'cancelled';
                      }).length,
                      revenue: encargos
                          .where((o) => o.status != 'cancelled')
                          .fold<double>(0, (s, o) => s + o.total),
                    ),
                  ),
                ),
                // ── Banner antelación mínima ───────────────────────
                SliverToBoxAdapter(
                  child: minDaysAsync
                          .whenData(
                            (days) => Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  24, 0, 24, 8),
                              child: _InfoBanner(
                                icon: Icons.info_outline_rounded,
                                color: AppTokens.brandPrimary,
                                text:
                                    'Antelación mínima actual: $days ${days == 1 ? "día" : "días"}. '
                                    'Configurable en Ajustes → Configuración.',
                              ),
                            ),
                          )
                          .value ??
                      const SizedBox.shrink(),
                ),
                // ── Toolbar ────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                  sliver: SliverToBoxAdapter(
                    child: _ToolbarCard(
                      statusFilter: _statusFilter,
                      onStatusChanged: (v) =>
                          setState(() => _statusFilter = v),
                      onSearchChanged: (v) =>
                          setState(() => _search = v.toLowerCase().trim()),
                    ),
                  ),
                ),
                if (encargos.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      icon: Icons.assignment_turned_in_outlined,
                      label: 'No hay encargos pendientes',
                      subtitle: 'Los nuevos encargos aparecerán aquí',
                    ),
                  )
                else if (filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      icon: Icons.search_off_rounded,
                      label: 'Sin resultados',
                      subtitle: 'Prueba con otro filtro o búsqueda',
                    ),
                  )
                else ...[
                  if (filteredPending.isNotEmpty)
                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 8, 24, 6),
                      sliver: SliverToBoxAdapter(
                        child: _SectionHeader(
                          title: 'Pendientes de aprobación',
                          count: filteredPending.length,
                          color: AppTokens.warning,
                        ),
                      ),
                    ),
                  if (filteredPending.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _EncargoCard(
                              order: filteredPending[i],
                              showActions: true,
                              index: i,
                            ),
                          ),
                          childCount: filteredPending.length,
                        ),
                      ),
                    ),
                  if (filteredOthers.isNotEmpty)
                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 20, 24, 6),
                      sliver: SliverToBoxAdapter(
                        child: _SectionHeader(
                          title: 'Aprobados / En preparación',
                          count: filteredOthers.length,
                          color: AppTokens.brandPrimary,
                        ),
                      ),
                    ),
                  if (filteredOthers.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _EncargoCard(
                              order: filteredOthers[i],
                              showActions: false,
                              index: i,
                            ),
                          ),
                          childCount: filteredOthers.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── KPI strip ──────────────────────────────────────────────────────────────

class _EncargosKpiStrip extends StatelessWidget {
  const _EncargosKpiStrip({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.urgent,
    required this.revenue,
  });
  final int total;
  final int pending;
  final int inProgress;
  final int urgent;
  final double revenue;

  @override
  Widget build(BuildContext context) {
    return _KpiStrip(
      items: [
        _Kpi(
          icon: Icons.assignment_rounded,
          color: AppTokens.brandPrimary,
          label: 'Encargos activos',
          value: '$total',
        ),
        _Kpi(
          icon: Icons.hourglass_top_rounded,
          color: AppTokens.warning,
          label: 'Pendientes aprobación',
          value: '$pending',
          subtitle: pending > 0 ? 'Acción requerida' : 'Sin pendientes',
        ),
        _Kpi(
          icon: Icons.outdoor_grill_rounded,
          color: AppTokens.info,
          label: 'En preparación',
          value: '$inProgress',
        ),
        _Kpi(
          icon: Icons.warning_amber_rounded,
          color: urgent > 0 ? AppTokens.danger : AppTokens.success,
          label: 'Urgentes ≤ 24h',
          value: '$urgent',
          subtitle: urgent > 0 ? '¡Revisar ya!' : 'Todo bajo control',
        ),
        _Kpi(
          icon: Icons.euro_rounded,
          color: AppTokens.success,
          label: 'Ingresos previstos',
          value: Formatters.price(revenue),
        ),
      ],
    );
  }
}

// ─── Toolbar ────────────────────────────────────────────────────────────────

class _ToolbarCard extends StatelessWidget {
  const _ToolbarCard({
    required this.statusFilter,
    required this.onStatusChanged,
    required this.onSearchChanged,
  });
  final String statusFilter;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kCardBorder),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar por #ID o notas...',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: _kInkSoft, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8F8FA),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kCardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kCardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppTokens.brandPrimary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Pill(
                  label: 'Todos',
                  selected: statusFilter == 'all',
                  color: _kInk,
                  onTap: () => onStatusChanged('all'),
                ),
                for (final e in _statusLabels.entries)
                  _Pill(
                    label: e.value,
                    selected: statusFilter == e.key,
                    color: _statusColor(e.key),
                    onTap: () => onStatusChanged(e.key),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Banner informativo ─────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 13, color: _kInkMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ─────────────────────────────────────────────────────────

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
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: _kInk,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Tarjeta de encargo ─────────────────────────────────────────────────────

class _EncargoCard extends ConsumerWidget {
  const _EncargoCard({
    required this.order,
    required this.showActions,
    required this.index,
  });
  final Order order;
  final bool showActions;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledDate = order.scheduledAt;
    final daysUntil = scheduledDate?.difference(DateTime.now()).inDays;
    final isUrgent = daysUntil != null && daysUntil <= 1;
    final barColor = _statusColor(order.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: isUrgent
              ? AppTokens.warning
              : _kCardBorder,
          width: isUrgent ? 1.5 : 1,
        ),
        boxShadow: [AppTokens.cardShadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(height: 3, color: barColor),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cabecera ──────────────────────────────────────
                Row(
                  children: [
                    Text(
                      '#${order.shortId}',
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _kInk,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _StatusChip(status: order.status),
                    const Spacer(),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTokens.warning,
                          borderRadius: BorderRadius.circular(
                              AppTokens.radiusSm),
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
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: _kCardBorder),
                const SizedBox(height: 12),

                // ── Fecha programada ─────────────────────────────
                if (scheduledDate != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.event_rounded,
                          size: 15, color: _kInkMuted),
                      const SizedBox(width: 8),
                      Text(
                        'Para el ${Formatters.date(scheduledDate)}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _kInk,
                        ),
                      ),
                      if (daysUntil != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isUrgent
                                ? AppTokens.warning.withValues(alpha: 0.12)
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
                              fontWeight: FontWeight.w700,
                              color: isUrgent
                                  ? AppTokens.warning
                                  : AppTokens.brandDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // ── Total ────────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.euro_rounded,
                        size: 15, color: _kInkMuted),
                    const SizedBox(width: 8),
                    Text(
                      'Total: ',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: _kInkMuted),
                    ),
                    Text(
                      Formatters.price(order.total),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _kInk,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Creado: ${Formatters.dateTime(order.createdAt)}',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: _kInkSoft),
                    ),
                  ],
                ),

                // ── Notas ────────────────────────────────────────
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFC),
                      border: Border.all(color: _kCardBorder),
                      borderRadius: BorderRadius.circular(
                          AppTokens.radiusSm),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.notes_rounded,
                            size: 14, color: _kInkSoft),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.notes!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: _kInkMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Pago ─────────────────────────────────────────
                const SizedBox(height: 10),
                _PaymentStatusBadge(order: order),

                // ── Acciones pendientes ──────────────────────────
                if (showActions) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: _kCardBorder),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _reject(context, ref),
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: Text('Rechazar',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTokens.danger,
                            side: const BorderSide(color: AppTokens.danger),
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
                                  fontWeight: FontWeight.w700,
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

                // ── Listo para recoger ───────────────────────────
                if (!showActions && order.status == 'ready') ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: _kCardBorder),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTokens.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                          AppTokens.radiusMd),
                      border: Border.all(
                          color: AppTokens.success.withValues(alpha: 0.3)),
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
                              fontWeight: FontWeight.w700,
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
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms, delay: (index * 30).ms)
        .slideY(begin: 0.04, end: 0, duration: 250.ms);
  }

  void _accept(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Aceptar encargo',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          '¿Confirmar el encargo #${order.shortId} y enviarlo a cocina?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: _kInkMuted)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminActionProvider.notifier).acceptEncargo(order.id);
            },
            style: FilledButton.styleFrom(
                backgroundColor: AppTokens.brandPrimary),
            child: Text('Aceptar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
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
          '¿Rechazar el encargo #${order.shortId}? El cliente será notificado.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: _kInkMuted)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminActionProvider.notifier).rejectEncargo(order.id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTokens.danger),
            child: Text('Rechazar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Chip de estado ─────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Text(
        _statusLabels[status] ?? status,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Badge de pago ──────────────────────────────────────────────────────────

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    if (order.paymentStatus == 'paid') {
      return _badge(Icons.check_circle_outline_rounded, 'Pagado',
          AppTokens.success);
    }
    return switch (order.paymentMethod) {
      'cash' => _badge(Icons.money_rounded,
          'Pendiente · Efectivo en local', AppTokens.warning),
      'tpv' => _badge(Icons.point_of_sale_rounded,
          'Pendiente · TPV en local', AppTokens.warning),
      'card' => _badge(Icons.credit_card_rounded,
          'Pendiente · Pago online', AppTokens.info),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.30)),
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
              fontSize: 11.5,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.label,
    this.subtitle,
  });
  final IconData icon;
  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
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
            child: Icon(icon, size: 36, color: AppTokens.brandPrimary),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _kInk,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.inter(fontSize: 13, color: _kInkMuted),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── KPI helpers ────────────────────────────────────────────────────────────

class _Kpi {
  const _Kpi({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? subtitle;
}

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.items});
  final List<_Kpi> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = c.maxWidth >= 1100
            ? 5
            : c.maxWidth >= 900
                ? 4
                : c.maxWidth >= 560
                    ? 2
                    : 1;
        const spacing = 14.0;
        final w = cols == 1
            ? c.maxWidth
            : (c.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final k in items)
              SizedBox(width: w, child: _KpiTile(data: k)),
          ],
        );
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.data});
  final _Kpi data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kCardBorder),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: _kInkMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                    height: 1.05,
                  ),
                ),
                if (data.subtitle != null)
                  Text(
                    data.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: _kInkSoft,
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

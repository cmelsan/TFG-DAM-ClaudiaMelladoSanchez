import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/core/widgets/order_card.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return AdminShell(
      title: 'Dashboard',
      child: statsAsync.when(
        data: (stats) => _DashboardBody(stats: stats),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(
          child: ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(adminDashboardStatsProvider),
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final revenue = (stats['revenue_total'] as num? ?? 0).toDouble();
    final ordersTotal = (stats['orders_total'] as num?)?.toInt() ?? 0;
    final ordersPending = (stats['orders_pending'] as num?)?.toInt() ?? 0;
    final usersTotal = (stats['users_total'] as num?)?.toInt() ?? 0;
    final contactsUnread = (stats['contacts_unread'] as num?)?.toInt() ?? 0;
    final eventsTotal = (stats['events_total'] as num?)?.toInt() ?? 0;

    final metrics = [
      (
        label: 'Ventas hoy',
        value: Formatters.price(revenue),
        icon: Icons.euro_rounded,
        color: AppTokens.brandPrimary,
      ),
      (
        label: 'Pedidos',
        value: ordersTotal.toString(),
        icon: Icons.receipt_long_outlined,
        color: AppTokens.info,
      ),
      (
        label: 'Pendientes',
        value: ordersPending.toString(),
        icon: Icons.pending_actions_outlined,
        color: AppTokens.warning,
      ),
      (
        label: 'Usuarios',
        value: usersTotal.toString(),
        icon: Icons.people_outline,
        color: AppTokens.brandDark,
      ),
      (
        label: 'Mensajes nuevos',
        value: contactsUnread.toString(),
        icon: Icons.mark_email_unread_outlined,
        color: AppTokens.danger,
      ),
      (
        label: 'Eventos catering',
        value: eventsTotal.toString(),
        icon: Icons.celebration_outlined,
        color: AppTokens.brandPrimary,
      ),
    ];

    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(24, 28, 24, 4),
          sliver: SliverToBoxAdapter(child: _PageHeader()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.crossAxisExtent >= 800
                  ? 4
                  : constraints.crossAxisExtent >= 500
                  ? 3
                  : 2;
              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _MetricTile(
                    label: metrics[i].label,
                    value: metrics[i].value,
                    icon: metrics[i].icon,
                    color: metrics[i].color,
                    delay: i * 60,
                  ),
                  childCount: metrics.length,
                ),
              );
            },
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(24, 28, 24, 8),
          sliver: SliverToBoxAdapter(child: SectionHeader('Accesos rapidos')),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 40),
          sliver: SliverToBoxAdapter(child: _QuickActions()),
        ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos dias'
        : hour < 19
        ? 'Buenas tardes'
        : 'Buenas noches';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting.toUpperCase(),
          style: GoogleFonts.bebasNeue(
            fontSize: 32,
            letterSpacing: 1.5,
            color: const Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Aqui tienes el resumen de hoy.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: const Color(0xFFE5E5E3), width: 0.5),
            boxShadow: [AppTokens.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888886),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 280.ms, delay: delay.ms)
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 280.ms,
          delay: delay.ms,
        );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.receipt_long_outlined, 'Ver pedidos', '/admin/orders'),
      (Icons.restaurant_menu, 'Gestionar platos', '/admin/dishes'),
      (Icons.bar_chart_rounded, 'Estadisticas', '/admin/stats'),
      (Icons.people_outline, 'Usuarios', '/admin/users'),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: actions
          .map(
            (a) => Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE5E5E3),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(a.$1, size: 16, color: AppTokens.brandPrimary),
                      const SizedBox(width: 8),
                      Text(
                        a.$2,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

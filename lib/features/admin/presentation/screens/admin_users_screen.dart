import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/domain/models/admin_user.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';

const _roleLabels = {
  'client': 'Cliente',
  'employee': 'Empleado',
  'admin': 'Admin',
};

Color _roleColor(String role) => switch (role) {
  'admin' => const Color(0xFF7C3AED),
  'employee' => AppTokens.brandPrimary,
  _ => AppTokens.info,
};

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA PRINCIPAL
// ─────────────────────────────────────────────────────────────────────────────

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _query = '';
  String _roleFilter = 'all'; // all | client | employee | admin
  String _stateFilter = 'all'; // all | active | inactive

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);
    final statsAsync = ref.watch(adminUsersStatsProvider);

    return AdminShell(
      title: 'Usuarios',
      actions: [
        IconButton(
          icon: const Icon(
            Icons.refresh_rounded,
            color: AppTokens.brandPrimary,
          ),
          tooltip: 'Actualizar',
          onPressed: () {
            ref
              ..invalidate(adminUsersProvider)
              ..invalidate(adminUsersStatsProvider);
          },
        ),
        const SizedBox(width: 8),
      ],
      child: usersAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(
          child: ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(adminUsersProvider),
          ),
        ),
        data: (users) {
          final stats = statsAsync.valueOrNull ?? const {};
          final filtered = _filter(users);

          final clients = users.where((u) => u.role == 'client').length;
          final employees = users.where((u) => u.role == 'employee').length;
          final admins = users.where((u) => u.role == 'admin').length;
          final inactive = users.where((u) => !u.isActive).length;

          return ColoredBox(
            color: const Color(0xFFF4F6F8),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              children: [
                // ── Resumen rápido ───────────────────────────────────
                _UsersSummary(
                  total: users.length,
                  clients: clients,
                  employees: employees,
                  admins: admins,
                  inactive: inactive,
                ),
                const SizedBox(height: 18),

                // ── Barra de filtros ─────────────────────────────────
                _FiltersBar(
                  query: _query,
                  roleFilter: _roleFilter,
                  stateFilter: _stateFilter,
                  onQuery: (v) => setState(() => _query = v),
                  onRole: (v) => setState(() => _roleFilter = v),
                  onState: (v) => setState(() => _stateFilter = v),
                  onExport: () => _exportCsv(filtered, stats),
                ),
                const SizedBox(height: 14),

                // ── Lista ────────────────────────────────────────────
                if (filtered.isEmpty)
                  _EmptyResults(query: _query)
                else
                  ...filtered.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _UserTile(
                        user: e.value,
                        index: e.key,
                        stats: stats[e.value.id],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<AdminUser> _filter(List<AdminUser> all) {
    final q = _query.trim().toLowerCase();
    return all.where((u) {
      if (_roleFilter != 'all' && u.role != _roleFilter) return false;
      if (_stateFilter == 'active' && !u.isActive) return false;
      if (_stateFilter == 'inactive' && u.isActive) return false;
      if (q.isEmpty) return true;
      return (u.fullName ?? '').toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          (u.phone ?? '').toLowerCase().contains(q);
    }).toList();
  }

  void _exportCsv(
    List<AdminUser> users,
    Map<String, Map<String, dynamic>> stats,
  ) {
    final buffer = StringBuffer(
      'nombre,email,telefono,rol,activo,pedidos,total_gastado,ultimo_pedido,creado\n',
    );
    for (final u in users) {
      final s = stats[u.id];
      final last = s?['last_order_at'] as DateTime?;
      buffer
        ..write('"${u.fullName ?? ''}",')
        ..write('"${u.email}",')
        ..write('"${u.phone ?? ''}",')
        ..write('${u.role},')
        ..write('${u.isActive},')
        ..write('${s?['orders_count'] ?? 0},')
        ..write('${(s?['total_spent'] as num?)?.toStringAsFixed(2) ?? '0'},')
        ..write('${last?.toIso8601String() ?? ''},')
        ..write(u.createdAt?.toIso8601String() ?? '')
        ..writeln();
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'CSV copiado al portapapeles (${users.length} filas)',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: AppTokens.brandPrimary,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESUMEN
// ─────────────────────────────────────────────────────────────────────────────

class _UsersSummary extends StatelessWidget {
  const _UsersSummary({
    required this.total,
    required this.clients,
    required this.employees,
    required this.admins,
    required this.inactive,
  });
  final int total;
  final int clients;
  final int employees;
  final int admins;
  final int inactive;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Total', '$total', AppTokens.brandDark),
      ('Clientes', '$clients', AppTokens.info),
      ('Empleados', '$employees', AppTokens.brandPrimary),
      ('Admins', '$admins', const Color(0xFF7C3AED)),
      ('Inactivos', '$inactive', AppTokens.danger),
    ];
    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = c.maxWidth >= 760 ? 5 : (c.maxWidth >= 480 ? 3 : 2);
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final it in items)
              SizedBox(
                width: (c.maxWidth - 12 * (cols - 1)) / cols,
                child: _SummaryChip(label: it.$1, value: it.$2, color: it.$3),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A2E),
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

// ─────────────────────────────────────────────────────────────────────────────
// FILTROS
// ─────────────────────────────────────────────────────────────────────────────

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.query,
    required this.roleFilter,
    required this.stateFilter,
    required this.onQuery,
    required this.onRole,
    required this.onState,
    required this.onExport,
  });
  final String query;
  final String roleFilter;
  final String stateFilter;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onRole;
  final ValueChanged<String> onState;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;

          final searchField = SizedBox(
            width: wide ? 320 : 280,
            child: TextField(
              onChanged: onQuery,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, email o teléfono…',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF9CA3AF),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xFFF4F6F8),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          );

          final roleDropdown = _FilterDropdown(
            value: roleFilter,
            onChanged: onRole,
            items: const {
              'all': 'Todos los roles',
              'client': 'Clientes',
              'employee': 'Empleados',
              'admin': 'Admins',
            },
          );

          final stateDropdown = _FilterDropdown(
            value: stateFilter,
            onChanged: onState,
            items: const {
              'all': 'Cualquier estado',
              'active': 'Activos',
              'inactive': 'Inactivos',
            },
          );

          final exportButton = OutlinedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Exportar CSV'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTokens.brandDark,
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          );

          if (wide) {
            return Row(
              children: [
                searchField,
                const SizedBox(width: 12),
                roleDropdown,
                const SizedBox(width: 12),
                stateDropdown,
                const Spacer(),
                exportButton,
              ],
            );
          }

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              searchField,
              roleDropdown,
              stateDropdown,
              exportButton,
            ],
          );
        },
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.onChanged,
    required this.items,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final Map<String, String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(
            Icons.expand_more_rounded,
            color: Color(0xFF6B7280),
          ),
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A2E),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          items: items.entries
              .map(
                (e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value, style: GoogleFonts.inter(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SIN RESULTADOS
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_search_rounded,
              color: Color(0xFF9CA3AF),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            query.isEmpty
                ? 'No hay usuarios que cumplan los filtros'
                : 'Sin coincidencias para "$query"',
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TILE DE USUARIO ENRIQUECIDO
// ─────────────────────────────────────────────────────────────────────────────

class _UserTile extends ConsumerWidget {
  const _UserTile({
    required this.user,
    required this.index,
    required this.stats,
  });
  final AdminUser user;
  final int index;
  final Map<String, dynamic>? stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rc = _roleColor(user.role);
    final initials = (user.fullName ?? user.email).isNotEmpty
        ? (user.fullName ?? user.email)[0].toUpperCase()
        : '?';
    final ordersCount = (stats?['orders_count'] as int?) ?? 0;
    final totalSpent = (stats?['total_spent'] as num?)?.toDouble() ?? 0;
    final lastOrder = stats?['last_order_at'] as DateTime?;

    return InkWell(
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      onTap: () => _openDetail(context, ref, user, stats),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [AppTokens.cardShadow],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: rc.withValues(alpha: 0.12),
                child: Text(
                  initials,
                  style: GoogleFonts.inter(
                    color: rc,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Nombre + email + teléfono
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.fullName ?? 'Sin nombre',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        if (!user.isActive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTokens.dangerBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'BLOQUEADO',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppTokens.danger,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      user.email,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF8A8FA8),
                      ),
                    ),
                  ],
                ),
              ),

              // Métricas de pedidos
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    _MiniStat(
                      label: 'Pedidos',
                      value: '$ordersCount',
                      color: AppTokens.info,
                    ),
                    const SizedBox(width: 10),
                    _MiniStat(
                      label: 'Gastado',
                      value: Formatters.price(totalSpent),
                      color: AppTokens.brandPrimary,
                    ),
                    const SizedBox(width: 10),
                    _MiniStat(
                      label: 'Último',
                      value: lastOrder == null
                          ? '—'
                          : DateFormat('dd/MM').format(lastOrder),
                      color: const Color(0xFF7C3AED),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Rol dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: rc.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  border: Border.all(color: rc.withValues(alpha: 0.25)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: user.role,
                    isDense: true,
                    style: GoogleFonts.inter(
                      color: rc,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.expand_more_rounded, size: 14, color: rc),
                    items: _roleLabels.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(
                              e.value,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (newRole) {
                      if (newRole == null || newRole == user.role) return;
                      ref
                          .read(adminActionProvider.notifier)
                          .updateUserRole(userId: user.id, role: newRole);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Activo toggle
              Switch(
                value: user.isActive,
                activeThumbColor: AppTokens.brandPrimary,
                onChanged: (v) => ref
                    .read(adminActionProvider.notifier)
                    .updateUserActive(userId: user.id, isActive: v),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 220.ms, delay: (index * 30).ms);
  }

  void _openDetail(
    BuildContext context,
    WidgetRef ref,
    AdminUser user,
    Map<String, dynamic>? stats,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _UserDetailSheet(user: user, stats: stats),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHEET DE DETALLE
// ─────────────────────────────────────────────────────────────────────────────

class _UserDetailSheet extends StatelessWidget {
  const _UserDetailSheet({required this.user, required this.stats});
  final AdminUser user;
  final Map<String, dynamic>? stats;

  @override
  Widget build(BuildContext context) {
    final rc = _roleColor(user.role);
    final ordersCount = (stats?['orders_count'] as int?) ?? 0;
    final totalSpent = (stats?['total_spent'] as num?)?.toDouble() ?? 0;
    final lastOrder = stats?['last_order_at'] as DateTime?;
    final created = user.createdAt;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: rc.withValues(alpha: 0.15),
                child: Text(
                  (user.fullName ?? user.email).substring(0, 1).toUpperCase(),
                  style: GoogleFonts.inter(
                    color: rc,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? 'Sin nombre',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      user.email,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DetailMetric(
                label: 'Pedidos',
                value: '$ordersCount',
                icon: Icons.receipt_long_rounded,
                color: AppTokens.info,
              ),
              _DetailMetric(
                label: 'Total gastado',
                value: Formatters.price(totalSpent),
                icon: Icons.payments_rounded,
                color: AppTokens.brandPrimary,
              ),
              _DetailMetric(
                label: 'Último pedido',
                value: lastOrder == null
                    ? '—'
                    : DateFormat('dd MMM yyyy', 'es').format(lastOrder),
                icon: Icons.event_rounded,
                color: const Color(0xFF7C3AED),
              ),
              _DetailMetric(
                label: 'Alta',
                value: created == null
                    ? '—'
                    : DateFormat('dd MMM yyyy', 'es').format(created),
                icon: Icons.calendar_today_rounded,
                color: AppTokens.brandDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoRow(label: 'Email', value: user.email),
          _InfoRow(label: 'Teléfono', value: user.phone ?? '—'),
          _InfoRow(label: 'Rol', value: _roleLabels[user.role] ?? user.role),
          _InfoRow(label: 'Estado', value: user.isActive ? 'Activo' : 'Bloqueado'),
        ],
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A2E),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

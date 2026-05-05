import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/domain/models/schedule_entry.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';

const _dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const _dayFull = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

class AdminScheduleScreen extends ConsumerWidget {
  const AdminScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(adminScheduleProvider);

    return AdminShell(
      title: 'Horarios',
      child: scheduleAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminScheduleProvider),
        ),
        data: (entries) {
          final sorted = [...entries]
            ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) =>
                _ScheduleTile(entry: sorted[i], index: i, ref: ref),
          );
        },
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.entry,
    required this.index,
    required this.ref,
  });

  final ScheduleEntry entry;
  final int index;
  final WidgetRef ref;

  String get _dayLabel {
    final d = entry.dayOfWeek - 1;
    return (d >= 0 && d < _dayFull.length)
        ? _dayFull[d]
        : 'Día ${entry.dayOfWeek}';
  }

  String get _dayShort {
    final d = entry.dayOfWeek - 1;
    return (d >= 0 && d < _dayNames.length) ? _dayNames[d] : '?';
  }

  Future<void> _pickTime(BuildContext context, bool isOpen) async {
    final current = isOpen ? entry.openTime : entry.closeTime;
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isOpen ? 'Hora de apertura' : 'Hora de cierre',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTokens.brandPrimary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

    if (isOpen) {
      await ref
          .read(adminActionProvider.notifier)
          .updateScheduleHours(
            id: entry.id,
            openTime: formatted,
            closeTime: entry.closeTime,
          );
    } else {
      await ref
          .read(adminActionProvider.notifier)
          .updateScheduleHours(
            id: entry.id,
            openTime: entry.openTime,
            closeTime: formatted,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Día badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: entry.isOpen
                        ? AppTokens.brandPrimary.withValues(alpha: 0.12)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _dayShort,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: entry.isOpen
                            ? AppTokens.brandPrimary
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dayLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: entry.isOpen
                              ? const Color(0xFF111111)
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _TimeButton(
                            label: entry.openTime,
                            icon: Icons.wb_sunny_outlined,
                            enabled: entry.isOpen,
                            onTap: () => _pickTime(context, true),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '–',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          _TimeButton(
                            label: entry.closeTime,
                            icon: Icons.nightlight_outlined,
                            enabled: entry.isOpen,
                            onTap: () => _pickTime(context, false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Toggle
                Switch(
                  value: entry.isOpen,
                  activeThumbColor: AppTokens.brandPrimary,
                  onChanged: (v) => ref
                      .read(adminActionProvider.notifier)
                      .updateSchedule(id: entry.id, isOpen: v),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms, delay: (index * 50).ms)
        .slideX(begin: 0.05, end: 0, duration: 250.ms, delay: (index * 50).ms);
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFE5E5E3) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: enabled ? AppTokens.brandPrimary : Colors.grey.shade400,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: enabled ? const Color(0xFF111111) : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
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

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return AdminShell(
      title: 'Usuarios',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTokens.brandPrimary),
          tooltip: 'Actualizar',
          onPressed: () => ref.invalidate(adminUsersProvider),
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
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F0F0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.people_rounded,
                        size: 28, color: Color(0xFF9E9E9E)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No hay usuarios registrados',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF9E9E9E), fontSize: 14),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) => _UserTile(user: users[i], index: i),
          );
        },
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  const _UserTile({required this.user, required this.index});
  final AdminUser user;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rc = _roleColor(user.role);
    final initials = (user.fullName ?? user.email).isNotEmpty
        ? (user.fullName ?? user.email)[0].toUpperCase()
        : '?';

    return Container(
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
            // Avatar
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

            // Nombre + email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName ?? 'Sin nombre',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    user.email,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF8A8FA8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Rol dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFF1A1A2E))),
                          ))
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
    )
        .animate()
        .fadeIn(duration: 250.ms, delay: (index * 35).ms)
        .slideX(begin: 0.04, end: 0, duration: 250.ms, delay: (index * 35).ms);
  }
}

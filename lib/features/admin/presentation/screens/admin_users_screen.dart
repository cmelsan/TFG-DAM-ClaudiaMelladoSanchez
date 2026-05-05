import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return AdminShell(
      title: 'Usuarios',
      child: usersAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminUsersProvider),
        ),
        data: (users) {
          if (users.isEmpty) {
            return const Center(
              child: Text(
                'No hay usuarios',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) =>
                _UserTile(user: users[i], index: i, ref: ref),
          );
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.index, required this.ref});
  final AdminUser user;
  final int index;
  final WidgetRef ref;

  Color _roleColor(String role) {
    return switch (role) {
      'admin' => Colors.purple,
      'employee' => AppTokens.brandPrimary,
      _ => Colors.blueGrey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(user.role);
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
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: roleColor.withValues(alpha: 0.15),
                  child: Text(
                    (user.fullName ?? user.email).isNotEmpty
                        ? (user.fullName ?? user.email)[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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
                        user.fullName ?? 'Sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF111111),
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
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
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: user.role,
                      isDense: true,
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      icon: Icon(Icons.expand_more, size: 14, color: roleColor),
                      items: _roleLabels.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
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
        )
        .animate()
        .fadeIn(duration: 250.ms, delay: (index * 40).ms)
        .slideX(begin: 0.05, end: 0, duration: 250.ms, delay: (index * 40).ms);
  }
}

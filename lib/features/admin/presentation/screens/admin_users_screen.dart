import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Usuarios')),
      body: usersAsync.when(
        data: (users) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: users.length,
          itemBuilder: (_, index) {
            final user = users[index];
            return SwitchListTile(
              title: Text(user.fullName ?? user.email),
              subtitle: Text('Rol: ${user.role}'),
              value: user.isActive,
              onChanged: (value) => ref
                  .read(adminActionProvider.notifier)
                  .updateUserActive(userId: user.id, isActive: value),
            );
          },
        ),
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminUsersProvider),
        ),
      ),
    );
  }
}

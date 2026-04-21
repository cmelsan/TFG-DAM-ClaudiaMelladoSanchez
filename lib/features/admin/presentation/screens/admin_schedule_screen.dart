import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';

class AdminScheduleScreen extends ConsumerWidget {
  const AdminScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(adminScheduleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Horarios')),
      body: scheduleAsync.when(
        data: (entries) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: entries.length,
          itemBuilder: (_, index) {
            final entry = entries[index];
            return SwitchListTile(
              title: Text('Día ${entry.dayOfWeek}'),
              subtitle: Text('${entry.openTime} - ${entry.closeTime}'),
              value: entry.isOpen,
              onChanged: (value) => ref
                  .read(adminActionProvider.notifier)
                  .updateSchedule(id: entry.id, isOpen: value),
            );
          },
        ),
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminScheduleProvider),
        ),
      ),
    );
  }
}

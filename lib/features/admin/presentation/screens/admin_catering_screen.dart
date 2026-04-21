import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';

class AdminCateringScreen extends ConsumerWidget {
  const AdminCateringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(adminEventRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Catering')),
      body: requestsAsync.when(
        data: (requests) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: requests.length,
          itemBuilder: (_, index) {
            final request = requests[index];
            return Card(
              child: ListTile(
                title: Text(
                  'Evento ${request.id.substring(0, 8).toUpperCase()} - '
                  '${request.guestCount} pax',
                ),
                subtitle: Text(
                  '${request.location} • '
                  '${Formatters.date(request.eventDate)}',
                ),
                trailing: DropdownButton<String>(
                  value: request.status,
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Pendiente'),
                    ),
                    DropdownMenuItem(
                      value: 'quoted',
                      child: Text('Presupuestado'),
                    ),
                    DropdownMenuItem(
                      value: 'accepted',
                      child: Text('Aceptado'),
                    ),
                    DropdownMenuItem(
                      value: 'rejected',
                      child: Text('Rechazado'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completado'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    ref
                        .read(adminActionProvider.notifier)
                        .updateEventRequestStatus(
                          requestId: request.id,
                          status: value,
                        );
                  },
                ),
              ),
            );
          },
        ),
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminEventRequestsProvider),
        ),
      ),
    );
  }
}

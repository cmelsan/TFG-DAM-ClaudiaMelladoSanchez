import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/catering/presentation/providers/catering_provider.dart';

class MyCateringRequestsScreen extends ConsumerWidget {
  const MyCateringRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myCateringRequestsProvider);

    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      appBar: AppBar(
        title: const Text('Mis solicitudes de catering'),
        centerTitle: true,
      ),
      body: requestsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.black38),
              const SizedBox(height: 12),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(myCateringRequestsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return _EmptyState(
              onTap: () => context.goNamed(RouteNames.catering),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myCateringRequestsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _RequestCard(request: requests[i]),
            ),
          );
        },
      ),
    );
  }
}

// â”€â”€â”€ _EmptyState â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_available_outlined,
              size: 80,
              color: Colors.black26,
            ),
            const SizedBox(height: 20),
            const Text(
              'Aún no tienes solicitudes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Contrata nuestro servicio de catering para tu próximo evento',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Ver menús de catering'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ _RequestCard â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});
  final Map<String, dynamic> request;

  @override
  Widget build(BuildContext context) {
    final status = request['status'] as String? ?? 'pending';
    final guestCount = request['guest_count'] as int? ?? 0;
    final location = request['location'] as String? ?? '';
    final eventDate = request['event_date'] != null
        ? DateTime.tryParse(request['event_date'] as String)
        : null;
    final menuName =
        (request['event_menus'] as Map<String, dynamic>?)?['name'] as String? ??
        'Menú';
    final pricePerPerson =
        (request['event_menus'] as Map<String, dynamic>?)?['price_per_person']
            as num?;
    final createdAt = request['created_at'] != null
        ? DateTime.tryParse(request['created_at'] as String)
        : null;
    final notes = request['notes'] as String?;

    final (label, color) = _statusInfo(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    menuName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info rows
                _InfoRow(
                  icon: Icons.people_outline,
                  text: '$guestCount personas',
                ),
                if (eventDate != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text:
                        '${eventDate.day}/${eventDate.month}/${eventDate.year}',
                  ),
                ],
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.location_on_outlined, text: location),
                ],
                if (pricePerPerson != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.euro_outlined,
                    text:
                        'Estimado: ${(guestCount * pricePerPerson).toStringAsFixed(2)} €',
                  ),
                ],
                if (notes != null && notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTokens.pageBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      notes,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
                if (createdAt != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Solicitado el ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String label, Color color) _statusInfo(String status) {
    switch (status) {
      case 'pending':
        return ('Pendiente', Colors.orange.shade700);
      case 'presupuesto_enviado':
        return ('Presupuesto enviado', Colors.blue.shade700);
      case 'accepted':
        return ('Aceptado', AppTokens.brandPrimary);
      case 'rejected':
        return ('Rechazado', Colors.red.shade600);
      default:
        return (status, Colors.grey);
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.black45),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

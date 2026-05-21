import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/features/kitchen/data/repositories/employee_orders_repository.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';

// ── Modelo enriquecido para el panel de reparto ───────────────────────────────

class DeliveryDetail {
  const DeliveryDetail({
    required this.order,
    this.addressLabel,
    this.addressStreet,
    this.addressCity,
    this.addressPostalCode,
    this.clientName,
    this.clientPhone,
  });

  final Order order;
  final String? addressLabel;
  final String? addressStreet;
  final String? addressCity;
  final String? addressPostalCode;
  final String? clientName;
  final String? clientPhone;

  /// Dirección completa formateada para mostrar al repartidor.
  String get fullAddress {
    if (addressStreet == null) return 'Sin dirección registrada';
    final parts = <String>[
      addressStreet!,
      if (addressPostalCode != null) addressPostalCode!,
      if (addressCity != null) addressCity!,
    ];
    return parts.join(', ');
  }

  /// Etiqueta de la dirección (ej. "Casa", "Trabajo").
  String get label => addressLabel ?? 'Dirección';

  /// Nombre o identificador corto del cliente.
  String get clientDisplay =>
      clientName?.isNotEmpty == true ? clientName! : 'Cliente sin nombre';
}

// ── Provider ──────────────────────────────────────────────────────────────────

final deliveryDetailProvider =
    FutureProvider.autoDispose<List<DeliveryDetail>>((ref) async {
  final rawList = await ref
      .watch(employeeOrdersRepositoryProvider)
      .getDeliveryOrdersWithDetails();

  return rawList.map((raw) {
    final order = Order.fromJson(raw);
    final addr = raw['addresses'] as Map<String, dynamic>?;
    final profile = raw['profiles'] as Map<String, dynamic>?;

    return DeliveryDetail(
      order: order,
      addressLabel: addr?['label'] as String?,
      addressStreet: addr?['street'] as String?,
      addressCity: addr?['city'] as String?,
      addressPostalCode: addr?['postal_code'] as String?,
      clientName: profile?['full_name'] as String?,
      clientPhone: profile?['phone'] as String?,
    );
  }).toList();
});

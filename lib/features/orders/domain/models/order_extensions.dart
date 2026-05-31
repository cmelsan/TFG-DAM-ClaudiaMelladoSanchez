import 'package:sabor_de_casa/features/orders/domain/models/order.dart';

extension OrderShortId on Order {
  String get shortId {
    if (displayId != null) return displayId!;
    final prefix = switch (orderType) {
      'domicilio' => 'DOM',
      'recogida' => 'LOC',
      'encargo' => 'ENC',
      'mostrador' => 'MOS',
      _ => 'PED',
    };
    return '$prefix-${id.substring(0, 4).toUpperCase()}';
  }
}

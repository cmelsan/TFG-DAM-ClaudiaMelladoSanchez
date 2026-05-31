import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
class Order with _$Order {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Order({
    required String id,
    required String orderType,
    required String status,
    required String paymentStatus,
    required double subtotal,
    required double deliveryFee,
    required double total,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0.0) double discountAmount,
    String? userId,
    String? paymentMethod,
    String? addressId,
    DateTime? scheduledAt,
    String? notes,
    String? assignedDriverId,
    String? displayId,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item.freezed.dart';
part 'order_item.g.dart';

@freezed
class OrderItem with _$OrderItem {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory OrderItem({
    required String id,
    required String orderId,
    required String dishId,
    required int quantity,
    required double unitPrice,
    required double subtotal,
    String? notes,
    String? dishName,
    String? dishImageUrl,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

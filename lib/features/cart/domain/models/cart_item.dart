import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
class CartItem with _$CartItem {
  const factory CartItem({
    required String dishId,
    required String name,
    required double unitPrice,
    required int quantity,
    String? imageUrl,
    @Default([]) List<String> allergens,
    @Default(true) bool isAvailable,
    @Default(0) int prepTimeMin,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:sabor_de_casa/features/cart/domain/models/cart_item.dart';

part 'cart_state.freezed.dart';

@freezed
class CartState with _$CartState {
  const factory CartState.empty() = CartEmpty;

  const factory CartState.active({
    required List<CartItem> items,
    required double total,
  }) = CartActive;

  const factory CartState.checkout({
    required List<CartItem> items,
    required double total,
    required String orderType,
  }) = CartCheckout;
}

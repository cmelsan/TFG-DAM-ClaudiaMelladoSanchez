import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/cart/data/repositories/checkout_repository.dart';
import 'package:sabor_de_casa/features/cart/domain/models/cart_item.dart';

part 'checkout_provider.g.dart';

@riverpod
class CheckoutSubmit extends _$CheckoutSubmit {
  @override
  FutureOr<String?> build() => null;

  Future<void> submit({
    required List<CartItem> items,
    required String orderType,
    required String paymentMethod,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(checkoutRepositoryProvider).createOrder(
            items: items,
            orderType: orderType,
            notes: notes,
            paymentMethod: paymentMethod,
          ),
    );
  }
}

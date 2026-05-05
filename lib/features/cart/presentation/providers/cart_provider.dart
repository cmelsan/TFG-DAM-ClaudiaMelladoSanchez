import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:sabor_de_casa/features/cart/domain/models/cart_item.dart';
import 'package:sabor_de_casa/features/cart/domain/models/cart_state.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';

part 'cart_provider.g.dart';

@riverpod
List<CartItem> cartItems(
  // ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
  CartItemsRef ref,
) {
  final state = ref.watch(cartNotifierProvider);
  return state.when(
    empty: List.empty,
    active: (items, _) => items,
    checkout: (items, _, __) => items,
  );
}

@riverpod
int cartItemsCount(
  // ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
  CartItemsCountRef ref,
) {
  final items = ref.watch(cartItemsProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
}

@riverpod
double cartTotal(
  // ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
  CartTotalRef ref,
) {
  final items = ref.watch(cartItemsProvider);
  return items.fold<double>(
    0,
    (sum, item) => sum + (item.unitPrice * item.quantity),
  );
}

@Riverpod(keepAlive: true)
class CartNotifier extends _$CartNotifier {
  @override
  CartState build() => const CartState.empty();

  void addDish(Dish dish) {
    final items = _itemsFromState();
    final index = items.indexWhere((item) => item.dishId == dish.id);

    if (index >= 0) {
      final current = items[index];
      items[index] = current.copyWith(quantity: current.quantity + 1);
    } else {
      items.add(
        CartItem(
          dishId: dish.id,
          name: dish.name,
          unitPrice: dish.price,
          quantity: 1,
          imageUrl: dish.imageUrl,
          allergens: dish.allergens,
          isAvailable: dish.isAvailable,
          prepTimeMin: dish.prepTimeMin,
        ),
      );
    }

    _setActive(items);
  }

  void incrementItem(String dishId) {
    final items = _itemsFromState();
    final index = items.indexWhere((item) => item.dishId == dishId);
    if (index < 0) return;

    final current = items[index];
    items[index] = current.copyWith(quantity: current.quantity + 1);
    _setActive(items);
  }

  void decrementItem(String dishId) {
    final items = _itemsFromState();
    final index = items.indexWhere((item) => item.dishId == dishId);
    if (index < 0) return;

    final current = items[index];
    if (current.quantity <= 1) {
      items.removeAt(index);
    } else {
      items[index] = current.copyWith(quantity: current.quantity - 1);
    }

    _setActive(items);
  }

  void removeItem(String dishId) {
    final items = _itemsFromState()
      ..removeWhere((item) => item.dishId == dishId);
    _setActive(items);
  }

  void clearCart() {
    state = const CartState.empty();
  }

  void startCheckout(String orderType) {
    final items = _itemsFromState();
    if (items.isEmpty) {
      state = const CartState.empty();
      return;
    }

    state = CartState.checkout(
      items: items,
      total: _calculateTotal(items),
      orderType: orderType,
    );
  }

  void backToActive() {
    final items = _itemsFromState();
    _setActive(items);
  }

  List<CartItem> _itemsFromState() {
    return state.when(
      empty: () => <CartItem>[],
      active: (items, _) => List<CartItem>.from(items),
      checkout: (items, _, __) => List<CartItem>.from(items),
    );
  }

  void _setActive(List<CartItem> items) {
    if (items.isEmpty) {
      state = const CartState.empty();
      return;
    }

    state = CartState.active(items: items, total: _calculateTotal(items));
  }

  double _calculateTotal(List<CartItem> items) {
    return items.fold<double>(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
  }
}

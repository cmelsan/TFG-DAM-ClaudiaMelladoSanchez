// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartItemsHash() => r'fe56c3e1051b04d58ec7583de4eec15610e15e9c';

/// See also [cartItems].
@ProviderFor(cartItems)
final cartItemsProvider = AutoDisposeProvider<List<CartItem>>.internal(
  cartItems,
  name: r'cartItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartItemsRef = AutoDisposeProviderRef<List<CartItem>>;
String _$cartItemsCountHash() => r'2559c70cb0c453055704ec0c3c158f6923f02dc1';

/// See also [cartItemsCount].
@ProviderFor(cartItemsCount)
final cartItemsCountProvider = AutoDisposeProvider<int>.internal(
  cartItemsCount,
  name: r'cartItemsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartItemsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartItemsCountRef = AutoDisposeProviderRef<int>;
String _$cartTotalHash() => r'173a2f3bb50a0a381dc931c3af61f7a7744b571f';

/// See also [cartTotal].
@ProviderFor(cartTotal)
final cartTotalProvider = AutoDisposeProvider<double>.internal(
  cartTotal,
  name: r'cartTotalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartTotalRef = AutoDisposeProviderRef<double>;
String _$cartNotifierHash() => r'aa0047ee0f4983b173fd121d1e21230c4136da41';

/// See also [CartNotifier].
@ProviderFor(CartNotifier)
final cartNotifierProvider = NotifierProvider<CartNotifier, CartState>.internal(
  CartNotifier.new,
  name: r'cartNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CartNotifier = Notifier<CartState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

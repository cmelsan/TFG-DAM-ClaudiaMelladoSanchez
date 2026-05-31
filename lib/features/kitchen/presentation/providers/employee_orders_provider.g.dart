// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$kitchenOrdersHash() => r'9469846d9827140533c3095c37b5168799bf9f2a';

/// See also [kitchenOrders].
@ProviderFor(kitchenOrders)
final kitchenOrdersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  kitchenOrders,
  name: r'kitchenOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kitchenOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KitchenOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$deliveryOrdersHash() => r'14594c76fd7e0417b728fc1e4aecb01a60a29098';

/// See also [deliveryOrders].
@ProviderFor(deliveryOrders)
final deliveryOrdersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  deliveryOrders,
  name: r'deliveryOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deliveryOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeliveryOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$posOrdersHash() => r'19ebd8c205601b70f1644fb3e5dce960b587e408';

/// See also [posOrders].
@ProviderFor(posOrders)
final posOrdersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  posOrders,
  name: r'posOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$posOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PosOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$encargoKitchenOrdersHash() =>
    r'd17ad05fc999977b93b81c82d6067b549e4aabbe';

/// See also [encargoKitchenOrders].
@ProviderFor(encargoKitchenOrders)
final encargoKitchenOrdersProvider =
    AutoDisposeFutureProvider<List<Order>>.internal(
      encargoKitchenOrders,
      name: r'encargoKitchenOrdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$encargoKitchenOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EncargoKitchenOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$pickupReadyOrdersHash() => r'da15d83272ebf09997f4afe197a05a73660e3259';

/// See also [pickupReadyOrders].
@ProviderFor(pickupReadyOrders)
final pickupReadyOrdersProvider =
    AutoDisposeFutureProvider<List<Order>>.internal(
      pickupReadyOrders,
      name: r'pickupReadyOrdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pickupReadyOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PickupReadyOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$orderForPickupHash() => r'556da8ae44df30693640e17ae05cc52672a7336a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [orderForPickup].
@ProviderFor(orderForPickup)
const orderForPickupProvider = OrderForPickupFamily();

/// See also [orderForPickup].
class OrderForPickupFamily extends Family<AsyncValue<Order?>> {
  /// See also [orderForPickup].
  const OrderForPickupFamily();

  /// See also [orderForPickup].
  OrderForPickupProvider call(String orderId) {
    return OrderForPickupProvider(orderId);
  }

  @override
  OrderForPickupProvider getProviderOverride(
    covariant OrderForPickupProvider provider,
  ) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderForPickupProvider';
}

/// See also [orderForPickup].
class OrderForPickupProvider extends AutoDisposeFutureProvider<Order?> {
  /// See also [orderForPickup].
  OrderForPickupProvider(String orderId)
    : this._internal(
        (ref) => orderForPickup(ref as OrderForPickupRef, orderId),
        from: orderForPickupProvider,
        name: r'orderForPickupProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderForPickupHash,
        dependencies: OrderForPickupFamily._dependencies,
        allTransitiveDependencies:
            OrderForPickupFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderForPickupProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  Override overrideWith(
    FutureOr<Order?> Function(OrderForPickupRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderForPickupProvider._internal(
        (ref) => create(ref as OrderForPickupRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Order?> createElement() {
    return _OrderForPickupProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderForPickupProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderForPickupRef on AutoDisposeFutureProviderRef<Order?> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderForPickupProviderElement
    extends AutoDisposeFutureProviderElement<Order?>
    with OrderForPickupRef {
  _OrderForPickupProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderForPickupProvider).orderId;
}

String _$encargosHoyHash() => r'f5751e4b488a2e7d4b9794657219514b621972d9';

/// See also [encargosHoy].
@ProviderFor(encargosHoy)
final encargosHoyProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  encargosHoy,
  name: r'encargosHoyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$encargosHoyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EncargosHoyRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$encargosSemanaHash() => r'33c41252245c54835de465f8a69a19ee48270420';

/// See also [encargosSemana].
@ProviderFor(encargosSemana)
final encargosSemanaProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  encargosSemana,
  name: r'encargosSemanaProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$encargosSemanaHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EncargosSemanaRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$counterOrdersTodayHash() =>
    r'fcaaa9350e3a107ae054e7f6d05eb9459f314e57';

/// See also [counterOrdersToday].
@ProviderFor(counterOrdersToday)
final counterOrdersTodayProvider =
    AutoDisposeFutureProvider<List<Order>>.internal(
      counterOrdersToday,
      name: r'counterOrdersTodayProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$counterOrdersTodayHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CounterOrdersTodayRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$allKitchenOrdersTodayHash() =>
    r'7f7ccf59f3dcf200bb4b6dc7086211e8ed2f701d';

/// See also [allKitchenOrdersToday].
@ProviderFor(allKitchenOrdersToday)
final allKitchenOrdersTodayProvider =
    AutoDisposeFutureProvider<List<Order>>.internal(
      allKitchenOrdersToday,
      name: r'allKitchenOrdersTodayProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allKitchenOrdersTodayHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllKitchenOrdersTodayRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$employeeOrderActionHash() =>
    r'520c45437adac3d71caf5c6a9152096da9f38610';

/// See also [EmployeeOrderAction].
@ProviderFor(EmployeeOrderAction)
final employeeOrderActionProvider =
    AutoDisposeAsyncNotifierProvider<EmployeeOrderAction, void>.internal(
      EmployeeOrderAction.new,
      name: r'employeeOrderActionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$employeeOrderActionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EmployeeOrderAction = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

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
String _$employeeOrderActionHash() =>
    r'5f61198c5488b8f1c4ae4c8b5ab83d38970d3cbe';

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

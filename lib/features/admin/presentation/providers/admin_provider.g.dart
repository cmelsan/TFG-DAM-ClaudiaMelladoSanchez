// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminDashboardStatsHash() =>
    r'01d7998362099682fa73a7da923ef8109174c161';

/// See also [adminDashboardStats].
@ProviderFor(adminDashboardStats)
final adminDashboardStatsProvider =
    AutoDisposeFutureProvider<Map<String, double>>.internal(
      adminDashboardStats,
      name: r'adminDashboardStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminDashboardStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminDashboardStatsRef =
    AutoDisposeFutureProviderRef<Map<String, double>>;
String _$adminOrdersHash() => r'e7eb8705e4c04a4e38622dea686bd7e6c47b33a3';

/// See also [adminOrders].
@ProviderFor(adminOrders)
final adminOrdersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  adminOrders,
  name: r'adminOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$adminOrderItemsHash() => r'0ae925cd19b2dc97bfa8bdabcf06183413fbf9aa';

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

/// See also [adminOrderItems].
@ProviderFor(adminOrderItems)
const adminOrderItemsProvider = AdminOrderItemsFamily();

/// See also [adminOrderItems].
class AdminOrderItemsFamily extends Family<AsyncValue<List<OrderItem>>> {
  /// See also [adminOrderItems].
  const AdminOrderItemsFamily();

  /// See also [adminOrderItems].
  AdminOrderItemsProvider call(String orderId) {
    return AdminOrderItemsProvider(orderId);
  }

  @override
  AdminOrderItemsProvider getProviderOverride(
    covariant AdminOrderItemsProvider provider,
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
  String? get name => r'adminOrderItemsProvider';
}

/// See also [adminOrderItems].
class AdminOrderItemsProvider
    extends AutoDisposeFutureProvider<List<OrderItem>> {
  /// See also [adminOrderItems].
  AdminOrderItemsProvider(String orderId)
    : this._internal(
        (ref) => adminOrderItems(ref as AdminOrderItemsRef, orderId),
        from: adminOrderItemsProvider,
        name: r'adminOrderItemsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminOrderItemsHash,
        dependencies: AdminOrderItemsFamily._dependencies,
        allTransitiveDependencies:
            AdminOrderItemsFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  AdminOrderItemsProvider._internal(
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
    FutureOr<List<OrderItem>> Function(AdminOrderItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminOrderItemsProvider._internal(
        (ref) => create(ref as AdminOrderItemsRef),
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
  AutoDisposeFutureProviderElement<List<OrderItem>> createElement() {
    return _AdminOrderItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminOrderItemsProvider && other.orderId == orderId;
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
mixin AdminOrderItemsRef on AutoDisposeFutureProviderRef<List<OrderItem>> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _AdminOrderItemsProviderElement
    extends AutoDisposeFutureProviderElement<List<OrderItem>>
    with AdminOrderItemsRef {
  _AdminOrderItemsProviderElement(super.provider);

  @override
  String get orderId => (origin as AdminOrderItemsProvider).orderId;
}

String _$adminUserProfileHash() => r'a7f4be9e1de78e169acc716eacff88b3ec4af24e';

/// See also [adminUserProfile].
@ProviderFor(adminUserProfile)
const adminUserProfileProvider = AdminUserProfileFamily();

/// See also [adminUserProfile].
class AdminUserProfileFamily extends Family<AsyncValue<AdminUser?>> {
  /// See also [adminUserProfile].
  const AdminUserProfileFamily();

  /// See also [adminUserProfile].
  AdminUserProfileProvider call(String userId) {
    return AdminUserProfileProvider(userId);
  }

  @override
  AdminUserProfileProvider getProviderOverride(
    covariant AdminUserProfileProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'adminUserProfileProvider';
}

/// See also [adminUserProfile].
class AdminUserProfileProvider extends AutoDisposeFutureProvider<AdminUser?> {
  /// See also [adminUserProfile].
  AdminUserProfileProvider(String userId)
    : this._internal(
        (ref) => adminUserProfile(ref as AdminUserProfileRef, userId),
        from: adminUserProfileProvider,
        name: r'adminUserProfileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminUserProfileHash,
        dependencies: AdminUserProfileFamily._dependencies,
        allTransitiveDependencies:
            AdminUserProfileFamily._allTransitiveDependencies,
        userId: userId,
      );

  AdminUserProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<AdminUser?> Function(AdminUserProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminUserProfileProvider._internal(
        (ref) => create(ref as AdminUserProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AdminUser?> createElement() {
    return _AdminUserProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminUserProfileProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminUserProfileRef on AutoDisposeFutureProviderRef<AdminUser?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _AdminUserProfileProviderElement
    extends AutoDisposeFutureProviderElement<AdminUser?>
    with AdminUserProfileRef {
  _AdminUserProfileProviderElement(super.provider);

  @override
  String get userId => (origin as AdminUserProfileProvider).userId;
}

String _$adminCategoriesHash() => r'2ec2b3fbba5c010858e25b24dac6cd1660a70eac';

/// See also [adminCategories].
@ProviderFor(adminCategories)
final adminCategoriesProvider =
    AutoDisposeFutureProvider<List<Category>>.internal(
      adminCategories,
      name: r'adminCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminCategoriesRef = AutoDisposeFutureProviderRef<List<Category>>;
String _$adminDishesHash() => r'16e26c94824b98b9ce8112dd56ccb13267f526e1';

/// See also [adminDishes].
@ProviderFor(adminDishes)
final adminDishesProvider = AutoDisposeFutureProvider<List<Dish>>.internal(
  adminDishes,
  name: r'adminDishesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminDishesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminDishesRef = AutoDisposeFutureProviderRef<List<Dish>>;
String _$adminEventRequestsHash() =>
    r'357b42710d33bb50c1748c379190ab93c2dea0fc';

/// See also [adminEventRequests].
@ProviderFor(adminEventRequests)
final adminEventRequestsProvider =
    AutoDisposeFutureProvider<List<AdminEventRequest>>.internal(
      adminEventRequests,
      name: r'adminEventRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminEventRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminEventRequestsRef =
    AutoDisposeFutureProviderRef<List<AdminEventRequest>>;
String _$adminEventMenusHash() => r'87d32d4379e81e22100ef95aaf0755949dd6a814';

/// See also [adminEventMenus].
@ProviderFor(adminEventMenus)
final adminEventMenusProvider =
    AutoDisposeFutureProvider<List<EventMenu>>.internal(
      adminEventMenus,
      name: r'adminEventMenusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminEventMenusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminEventMenusRef = AutoDisposeFutureProviderRef<List<EventMenu>>;
String _$adminUsersHash() => r'ea6be1b626bc1aac297aa33547dee304217ec89c';

/// See also [adminUsers].
@ProviderFor(adminUsers)
final adminUsersProvider = AutoDisposeFutureProvider<List<AdminUser>>.internal(
  adminUsers,
  name: r'adminUsersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminUsersRef = AutoDisposeFutureProviderRef<List<AdminUser>>;
String _$adminConfigHash() => r'a528d61af7d3f8213cb89b1482fc32fcbdd40a28';

/// See also [adminConfig].
@ProviderFor(adminConfig)
final adminConfigProvider =
    AutoDisposeFutureProvider<List<BusinessConfigItem>>.internal(
      adminConfig,
      name: r'adminConfigProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminConfigHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminConfigRef = AutoDisposeFutureProviderRef<List<BusinessConfigItem>>;
String _$adminScheduleHash() => r'972aeb39ad6ac39d0cfe25e0008ee5fc8b67ed95';

/// See also [adminSchedule].
@ProviderFor(adminSchedule)
final adminScheduleProvider =
    AutoDisposeFutureProvider<List<ScheduleEntry>>.internal(
      adminSchedule,
      name: r'adminScheduleProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminScheduleHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminScheduleRef = AutoDisposeFutureProviderRef<List<ScheduleEntry>>;
String _$adminEncargosHash() => r'925dc13b08711c83185a1b05a5f60b70fc556752';

/// See also [adminEncargos].
@ProviderFor(adminEncargos)
final adminEncargosProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  adminEncargos,
  name: r'adminEncargosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminEncargosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminEncargosRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$encargoMinDaysHash() => r'0c3d2b0fb967aa3f1075807c0197182162f2fa6d';

/// See also [encargoMinDays].
@ProviderFor(encargoMinDays)
final encargoMinDaysProvider = AutoDisposeFutureProvider<int>.internal(
  encargoMinDays,
  name: r'encargoMinDaysProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$encargoMinDaysHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EncargoMinDaysRef = AutoDisposeFutureProviderRef<int>;
String _$showOffersSectionHash() => r'af6769ade3b02744ad755e3952fbfff2d0d4503f';

/// Controla si la sección "En oferta" debe mostrarse en la home web.
/// Editable desde el panel de configuración del admin.
///
/// Copied from [showOffersSection].
@ProviderFor(showOffersSection)
final showOffersSectionProvider = AutoDisposeFutureProvider<bool>.internal(
  showOffersSection,
  name: r'showOffersSectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showOffersSectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShowOffersSectionRef = AutoDisposeFutureProviderRef<bool>;
String _$showSeasonalSectionHash() =>
    r'ab23a55f26f6d1b34d32ce184bc0cbf4e0838bd7';

/// Controla si la sección "Platos de temporada" debe mostrarse en la home web.
/// Editable desde el panel de configuración del admin.
///
/// Copied from [showSeasonalSection].
@ProviderFor(showSeasonalSection)
final showSeasonalSectionProvider = AutoDisposeFutureProvider<bool>.internal(
  showSeasonalSection,
  name: r'showSeasonalSectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showSeasonalSectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShowSeasonalSectionRef = AutoDisposeFutureProviderRef<bool>;
String _$firstOrderDiscountEnabledHash() =>
    r'c02f7c0d45fdf33c334eb4b0de3bc57240e9e2f9';

/// Controla si el descuento del 30% al primer pedido está activo.
/// El admin puede activarlo/desactivarlo desde el panel de configuración.
///
/// Copied from [firstOrderDiscountEnabled].
@ProviderFor(firstOrderDiscountEnabled)
final firstOrderDiscountEnabledProvider =
    AutoDisposeFutureProvider<bool>.internal(
      firstOrderDiscountEnabled,
      name: r'firstOrderDiscountEnabledProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$firstOrderDiscountEnabledHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirstOrderDiscountEnabledRef = AutoDisposeFutureProviderRef<bool>;
String _$acceptingOrdersHash() => r'70416eafb87870eb9d4e6522776304b1b430748e';

/// Controla si el negocio está aceptando nuevos pedidos.
/// Cuando es false, el checkout bloquea los pedidos de domicilio y recogida.
///
/// Copied from [acceptingOrders].
@ProviderFor(acceptingOrders)
final acceptingOrdersProvider = AutoDisposeFutureProvider<bool>.internal(
  acceptingOrders,
  name: r'acceptingOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$acceptingOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AcceptingOrdersRef = AutoDisposeFutureProviderRef<bool>;
String _$adminActionHash() => r'a2bcd53185720aedda9dc45e414affca23c05d3f';

/// See also [AdminAction].
@ProviderFor(AdminAction)
final adminActionProvider =
    AutoDisposeAsyncNotifierProvider<AdminAction, void>.internal(
      AdminAction.new,
      name: r'adminActionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminActionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminAction = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

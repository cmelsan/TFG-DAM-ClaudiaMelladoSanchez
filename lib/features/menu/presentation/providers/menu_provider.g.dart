// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dishesHash() => r'0813a03fd84f6b85e777d6582b260be3b4aba151';

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

/// See also [dishes].
@ProviderFor(dishes)
const dishesProvider = DishesFamily();

/// See also [dishes].
class DishesFamily extends Family<AsyncValue<List<Dish>>> {
  /// See also [dishes].
  const DishesFamily();

  /// See also [dishes].
  DishesProvider call({String? categoryId}) {
    return DishesProvider(categoryId: categoryId);
  }

  @override
  DishesProvider getProviderOverride(covariant DishesProvider provider) {
    return call(categoryId: provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dishesProvider';
}

/// See also [dishes].
class DishesProvider extends AutoDisposeFutureProvider<List<Dish>> {
  /// See also [dishes].
  DishesProvider({String? categoryId})
    : this._internal(
        (ref) => dishes(ref as DishesRef, categoryId: categoryId),
        from: dishesProvider,
        name: r'dishesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$dishesHash,
        dependencies: DishesFamily._dependencies,
        allTransitiveDependencies: DishesFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  DishesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String? categoryId;

  @override
  Override overrideWith(
    FutureOr<List<Dish>> Function(DishesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DishesProvider._internal(
        (ref) => create(ref as DishesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Dish>> createElement() {
    return _DishesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DishesProvider && other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DishesRef on AutoDisposeFutureProviderRef<List<Dish>> {
  /// The parameter `categoryId` of this provider.
  String? get categoryId;
}

class _DishesProviderElement
    extends AutoDisposeFutureProviderElement<List<Dish>>
    with DishesRef {
  _DishesProviderElement(super.provider);

  @override
  String? get categoryId => (origin as DishesProvider).categoryId;
}

String _$offerDishesHash() => r'f0cebca38ea6c0ece968801609344c390ec15236';

/// See also [offerDishes].
@ProviderFor(offerDishes)
final offerDishesProvider = AutoDisposeFutureProvider<List<Dish>>.internal(
  offerDishes,
  name: r'offerDishesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$offerDishesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfferDishesRef = AutoDisposeFutureProviderRef<List<Dish>>;
String _$seasonalDishesHash() => r'123bd64000069c4f0d6cfe5c1abacafc13c7525a';

/// See also [seasonalDishes].
@ProviderFor(seasonalDishes)
final seasonalDishesProvider = AutoDisposeFutureProvider<List<Dish>>.internal(
  seasonalDishes,
  name: r'seasonalDishesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$seasonalDishesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SeasonalDishesRef = AutoDisposeFutureProviderRef<List<Dish>>;
String _$dishDetailHash() => r'f4deb27b82f958f45fa06ef6e2c6f79196c8c656';

/// See also [dishDetail].
@ProviderFor(dishDetail)
const dishDetailProvider = DishDetailFamily();

/// See also [dishDetail].
class DishDetailFamily extends Family<AsyncValue<Dish>> {
  /// See also [dishDetail].
  const DishDetailFamily();

  /// See also [dishDetail].
  DishDetailProvider call(String dishId) {
    return DishDetailProvider(dishId);
  }

  @override
  DishDetailProvider getProviderOverride(
    covariant DishDetailProvider provider,
  ) {
    return call(provider.dishId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dishDetailProvider';
}

/// See also [dishDetail].
class DishDetailProvider extends AutoDisposeFutureProvider<Dish> {
  /// See also [dishDetail].
  DishDetailProvider(String dishId)
    : this._internal(
        (ref) => dishDetail(ref as DishDetailRef, dishId),
        from: dishDetailProvider,
        name: r'dishDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$dishDetailHash,
        dependencies: DishDetailFamily._dependencies,
        allTransitiveDependencies: DishDetailFamily._allTransitiveDependencies,
        dishId: dishId,
      );

  DishDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.dishId,
  }) : super.internal();

  final String dishId;

  @override
  Override overrideWith(
    FutureOr<Dish> Function(DishDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DishDetailProvider._internal(
        (ref) => create(ref as DishDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        dishId: dishId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Dish> createElement() {
    return _DishDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DishDetailProvider && other.dishId == dishId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, dishId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DishDetailRef on AutoDisposeFutureProviderRef<Dish> {
  /// The parameter `dishId` of this provider.
  String get dishId;
}

class _DishDetailProviderElement extends AutoDisposeFutureProviderElement<Dish>
    with DishDetailRef {
  _DishDetailProviderElement(super.provider);

  @override
  String get dishId => (origin as DishDetailProvider).dishId;
}

String _$menuSearchQueryHash() => r'0c0574c92e1c2e2db208b364fd9b3de0b6ee292d';

/// See also [MenuSearchQuery].
@ProviderFor(MenuSearchQuery)
final menuSearchQueryProvider =
    AutoDisposeNotifierProvider<MenuSearchQuery, String>.internal(
      MenuSearchQuery.new,
      name: r'menuSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$menuSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MenuSearchQuery = AutoDisposeNotifier<String>;
String _$menuAllergenFilterHash() =>
    r'b9e4b21615d9bb0d0722caa253ea1b19730d3fd0';

/// See also [MenuAllergenFilter].
@ProviderFor(MenuAllergenFilter)
final menuAllergenFilterProvider =
    AutoDisposeNotifierProvider<MenuAllergenFilter, List<String>>.internal(
      MenuAllergenFilter.new,
      name: r'menuAllergenFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$menuAllergenFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MenuAllergenFilter = AutoDisposeNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

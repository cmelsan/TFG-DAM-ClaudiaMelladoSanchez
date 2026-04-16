// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$favoritesHash() => r'bffa230b5ef93d751648b2d8d5827b1507f09918';

/// See also [favorites].
@ProviderFor(favorites)
final favoritesProvider = AutoDisposeFutureProvider<List<Favorite>>.internal(
  favorites,
  name: r'favoritesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoritesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FavoritesRef = AutoDisposeFutureProviderRef<List<Favorite>>;
String _$isFavoriteHash() => r'787f356c6055158a5dcdf06568847dfa472cab97';

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

/// See also [isFavorite].
@ProviderFor(isFavorite)
const isFavoriteProvider = IsFavoriteFamily();

/// See also [isFavorite].
class IsFavoriteFamily extends Family<AsyncValue<bool>> {
  /// See also [isFavorite].
  const IsFavoriteFamily();

  /// See also [isFavorite].
  IsFavoriteProvider call(String dishId) {
    return IsFavoriteProvider(dishId);
  }

  @override
  IsFavoriteProvider getProviderOverride(
    covariant IsFavoriteProvider provider,
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
  String? get name => r'isFavoriteProvider';
}

/// See also [isFavorite].
class IsFavoriteProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [isFavorite].
  IsFavoriteProvider(String dishId)
    : this._internal(
        (ref) => isFavorite(ref as IsFavoriteRef, dishId),
        from: isFavoriteProvider,
        name: r'isFavoriteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isFavoriteHash,
        dependencies: IsFavoriteFamily._dependencies,
        allTransitiveDependencies: IsFavoriteFamily._allTransitiveDependencies,
        dishId: dishId,
      );

  IsFavoriteProvider._internal(
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
    FutureOr<bool> Function(IsFavoriteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsFavoriteProvider._internal(
        (ref) => create(ref as IsFavoriteRef),
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
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _IsFavoriteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFavoriteProvider && other.dishId == dishId;
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
mixin IsFavoriteRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `dishId` of this provider.
  String get dishId;
}

class _IsFavoriteProviderElement extends AutoDisposeFutureProviderElement<bool>
    with IsFavoriteRef {
  _IsFavoriteProviderElement(super.provider);

  @override
  String get dishId => (origin as IsFavoriteProvider).dishId;
}

String _$favoriteToggleHash() => r'278a2dbc3ddf37d95acf6b98f88f1047cf72271f';

/// See also [FavoriteToggle].
@ProviderFor(FavoriteToggle)
final favoriteToggleProvider =
    AutoDisposeAsyncNotifierProvider<FavoriteToggle, void>.internal(
      FavoriteToggle.new,
      name: r'favoriteToggleProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoriteToggleHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FavoriteToggle = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

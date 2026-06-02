// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userAllergensHash() => r'fd00d302d3b2a9f8f0720e16b50eab5470470ba1';

/// Devuelve los alérgenos del usuario autenticado (lista vacía si no hay sesión).
///
/// Copied from [userAllergens].
@ProviderFor(userAllergens)
final userAllergensProvider = AutoDisposeProvider<List<String>>.internal(
  userAllergens,
  name: r'userAllergensProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userAllergensHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserAllergensRef = AutoDisposeProviderRef<List<String>>;
String _$addressesNotifierHash() => r'89dd3126a27a61872a1a5870af8f96ea1043c7bd';

/// See also [AddressesNotifier].
@ProviderFor(AddressesNotifier)
final addressesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      AddressesNotifier,
      List<Map<String, dynamic>>
    >.internal(
      AddressesNotifier.new,
      name: r'addressesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$addressesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AddressesNotifier =
    AutoDisposeAsyncNotifier<List<Map<String, dynamic>>>;
String _$profileNotifierHash() => r'c94c5f572063682c9e101e48ade2880bbcc2ddf6';

/// See also [ProfileNotifier].
@ProviderFor(ProfileNotifier)
final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfile>.internal(
      ProfileNotifier.new,
      name: r'profileNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProfileNotifier = AsyncNotifier<UserProfile>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

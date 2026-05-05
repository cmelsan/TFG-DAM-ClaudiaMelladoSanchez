// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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
String _$profileNotifierHash() => r'aa81eb18929bde4540407d33be6930c0e73b743c';

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

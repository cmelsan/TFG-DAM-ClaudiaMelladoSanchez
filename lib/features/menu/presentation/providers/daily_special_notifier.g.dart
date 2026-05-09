// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_special_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailySpecialNotifierHash() =>
    r'604000fa08d770ee4ccb9cc5b4d2d143d26b9c0a';

/// Notifier para gestionar el menú del día desde el panel de admin.
/// Expone el estado actual y un método [upsert] para crear/actualizar.
///
/// Copied from [DailySpecialNotifier].
@ProviderFor(DailySpecialNotifier)
final dailySpecialNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      DailySpecialNotifier,
      DailySpecial?
    >.internal(
      DailySpecialNotifier.new,
      name: r'dailySpecialNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dailySpecialNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DailySpecialNotifier = AutoDisposeAsyncNotifier<DailySpecial?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

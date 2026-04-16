// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_special_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todaySpecialHash() => r'020d1bb51fa1268608882d354a1ca34889e539ce';

/// Plato del día con el Dish incluido para mostrar toda la info.
///
/// Copied from [todaySpecial].
@ProviderFor(todaySpecial)
final todaySpecialProvider =
    AutoDisposeFutureProvider<({DailySpecial special, Dish dish})?>.internal(
      todaySpecial,
      name: r'todaySpecialProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todaySpecialHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodaySpecialRef =
    AutoDisposeFutureProviderRef<({DailySpecial special, Dish dish})?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

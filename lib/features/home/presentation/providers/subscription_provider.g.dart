// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionNotifierHash() =>
    r'dc232937015c15172d2ab676b5f5ff31fe8609e1';

/// Notifier para gestionar las suscripciones de newsletter / WhatsApp.
///
/// Copied from [SubscriptionNotifier].
@ProviderFor(SubscriptionNotifier)
final subscriptionNotifierProvider =
    AutoDisposeNotifierProvider<
      SubscriptionNotifier,
      SubscriptionStatus
    >.internal(
      SubscriptionNotifier.new,
      name: r'subscriptionNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$subscriptionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SubscriptionNotifier = AutoDisposeNotifier<SubscriptionStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

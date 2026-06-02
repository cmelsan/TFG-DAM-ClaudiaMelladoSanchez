// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newsletter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$newsletterSubscribersHash() =>
    r'b7283919654469a5c82c9350a8b80deb05e97e70';

/// See also [newsletterSubscribers].
@ProviderFor(newsletterSubscribers)
final newsletterSubscribersProvider =
    AutoDisposeFutureProvider<List<NewsletterSubscriber>>.internal(
      newsletterSubscribers,
      name: r'newsletterSubscribersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$newsletterSubscribersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NewsletterSubscribersRef =
    AutoDisposeFutureProviderRef<List<NewsletterSubscriber>>;
String _$newsletterActionHash() => r'87aa9284372d6e7c67b20d4e5024e5fa52200e0d';

/// See also [NewsletterAction].
@ProviderFor(NewsletterAction)
final newsletterActionProvider =
    AutoDisposeAsyncNotifierProvider<NewsletterAction, void>.internal(
      NewsletterAction.new,
      name: r'newsletterActionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$newsletterActionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NewsletterAction = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

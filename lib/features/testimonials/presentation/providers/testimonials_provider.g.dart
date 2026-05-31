// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'testimonials_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminTestimonialsHash() => r'd565a63bb51f0c1c2cc3ed163793fd1faa9219ef';

/// See also [adminTestimonials].
@ProviderFor(adminTestimonials)
final adminTestimonialsProvider =
    AutoDisposeFutureProvider<List<Testimonial>>.internal(
      adminTestimonials,
      name: r'adminTestimonialsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminTestimonialsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminTestimonialsRef = AutoDisposeFutureProviderRef<List<Testimonial>>;
String _$testimonialActionHash() => r'7d15c9352ae39396d5ec452cc01661577879a4c0';

/// See also [TestimonialAction].
@ProviderFor(TestimonialAction)
final testimonialActionProvider =
    AutoDisposeAsyncNotifierProvider<TestimonialAction, void>.internal(
      TestimonialAction.new,
      name: r'testimonialActionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$testimonialActionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TestimonialAction = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

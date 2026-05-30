// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'testimonials_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$testimonialsHash() => r'ef915bcd0917649c83f5678336aba6a3061b09da';

/// Obtiene los testimonios destacados desde Supabase.
/// Acceso público (SELECT policy sin auth).
///
/// Copied from [testimonials].
@ProviderFor(testimonials)
final testimonialsProvider =
    AutoDisposeFutureProvider<List<TestimonialModel>>.internal(
      testimonials,
      name: r'testimonialsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$testimonialsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TestimonialsRef = AutoDisposeFutureProviderRef<List<TestimonialModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

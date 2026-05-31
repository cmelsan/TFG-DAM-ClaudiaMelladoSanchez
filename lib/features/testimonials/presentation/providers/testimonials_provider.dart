import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/testimonials/data/repositories/testimonials_repository.dart';
import 'package:sabor_de_casa/features/testimonials/domain/models/testimonial.dart';

part 'testimonials_provider.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package
Future<List<Testimonial>> adminTestimonials(AdminTestimonialsRef ref) {
  return ref.watch(testimonialsRepositoryProvider).listAll();
}

@riverpod
class TestimonialAction extends _$TestimonialAction {
  @override
  FutureOr<void> build() {
    ref.keepAlive();
  }

  Future<void> create({
    required String authorName,
    required String body,
    required int rating,
    required bool isFeatured,
    int position = 0,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(testimonialsRepositoryProvider).create(
            authorName: authorName,
            body: body,
            rating: rating,
            isFeatured: isFeatured,
            position: position,
          ),
    );
    ref.invalidate(adminTestimonialsProvider);
  }

  Future<void> updateOne({
    required String id,
    String? authorName,
    String? body,
    int? rating,
    bool? isFeatured,
    int? position,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(testimonialsRepositoryProvider).update(
            id: id,
            authorName: authorName,
            body: body,
            rating: rating,
            isFeatured: isFeatured,
            position: position,
          ),
    );
    ref.invalidate(adminTestimonialsProvider);
  }

  Future<void> remove(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(testimonialsRepositoryProvider).remove(id),
    );
    ref.invalidate(adminTestimonialsProvider);
  }
}

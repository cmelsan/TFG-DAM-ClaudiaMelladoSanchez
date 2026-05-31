import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/testimonials/domain/models/testimonial.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'testimonials_repository.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
TestimonialsRepository testimonialsRepository(TestimonialsRepositoryRef ref) {
  return TestimonialsRepository(ref.watch(supabaseClientProvider));
}

class TestimonialsRepository {
  TestimonialsRepository(this._client);

  static const _table = 'testimonials';
  final SupabaseClient _client;

  Future<List<Testimonial>> listAll() async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .order('position', ascending: true)
          .order('created_at', ascending: false);
      return data.map(Testimonial.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> create({
    required String authorName,
    required String body,
    required int rating,
    required bool isFeatured,
    int position = 0,
  }) async {
    try {
      await _client.from(_table).insert({
        'author_name': authorName,
        'body': body,
        'rating': rating,
        'is_featured': isFeatured,
        'position': position,
      });
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> update({
    required String id,
    String? authorName,
    String? body,
    int? rating,
    bool? isFeatured,
    int? position,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (authorName != null) 'author_name': authorName,
        if (body != null) 'body': body,
        if (rating != null) 'rating': rating,
        if (isFeatured != null) 'is_featured': isFeatured,
        if (position != null) 'position': position,
      };
      if (payload.isEmpty) return;
      await _client.from(_table).update(payload).eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> remove(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}

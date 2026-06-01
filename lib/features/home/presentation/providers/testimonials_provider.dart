import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'testimonials_provider.g.dart';

/// Modelo ligero de un testimonio público.
class TestimonialModel {
  const TestimonialModel({
    required this.authorName,
    required this.body,
    required this.rating,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) =>
      TestimonialModel(
        authorName: json['author_name'] as String? ?? 'Cliente',
        body: json['body'] as String? ?? '',
        rating: json['rating'] as int? ?? 5,
      );

  final String authorName;
  final String body;
  final int rating;
}

/// Obtiene los testimonios destacados desde Supabase.
/// Acceso público (SELECT policy sin auth).
@riverpod
Future<List<TestimonialModel>> testimonials(
  TestimonialsRef ref, // ignore: deprecated_member_use_from_same_package
) async {
  final data = await Supabase.instance.client
      .from('testimonials')
      .select('author_name, body, rating')
      .eq('is_featured', true)
      .order('position', ascending: true)
      .limit(6);

  return (data as List)
      .map((e) => TestimonialModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

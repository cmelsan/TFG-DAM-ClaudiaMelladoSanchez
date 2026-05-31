import 'package:freezed_annotation/freezed_annotation.dart';

part 'testimonial.freezed.dart';
part 'testimonial.g.dart';

@freezed
class Testimonial with _$Testimonial {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Testimonial({
    required String id,
    required String authorName,
    required String body,
    required int rating,
    required bool isFeatured,
    required int position,
    required DateTime createdAt,
  }) = _Testimonial;

  factory Testimonial.fromJson(Map<String, dynamic> json) =>
      _$TestimonialFromJson(json);
}

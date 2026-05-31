// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'testimonial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TestimonialImpl _$$TestimonialImplFromJson(Map<String, dynamic> json) =>
    _$TestimonialImpl(
      id: json['id'] as String,
      authorName: json['author_name'] as String,
      body: json['body'] as String,
      rating: (json['rating'] as num).toInt(),
      isFeatured: json['is_featured'] as bool,
      position: (json['position'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TestimonialImplToJson(_$TestimonialImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_name': instance.authorName,
      'body': instance.body,
      'rating': instance.rating,
      'is_featured': instance.isFeatured,
      'position': instance.position,
      'created_at': instance.createdAt.toIso8601String(),
    };

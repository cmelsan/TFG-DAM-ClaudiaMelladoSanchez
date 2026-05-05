// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventMenuImpl _$$EventMenuImplFromJson(Map<String, dynamic> json) =>
    _$EventMenuImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      pricePerPerson: (json['price_per_person'] as num).toDouble(),
      minGuests: (json['min_guests'] as num).toInt(),
      maxGuests: (json['max_guests'] as num).toInt(),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$EventMenuImplToJson(_$EventMenuImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price_per_person': instance.pricePerPerson,
      'min_guests': instance.minGuests,
      'max_guests': instance.maxGuests,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventMenu _$EventMenuFromJson(Map<String, dynamic> json) => EventMenu(
  id: json['id'] as String,
  name: json['name'] as String,
  pricePerPerson: (json['price_per_person'] as num).toDouble(),
  minGuests: (json['min_guests'] as num).toInt(),
  maxGuests: (json['max_guests'] as num).toInt(),
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  isActive: json['is_active'] as bool,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$EventMenuToJson(EventMenu instance) => <String, dynamic>{
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

_$EventMenuImpl _$$EventMenuImplFromJson(Map<String, dynamic> json) =>
    _$EventMenuImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      pricePerPerson: (json['pricePerPerson'] as num).toDouble(),
      minGuests: (json['minGuests'] as num).toInt(),
      maxGuests: (json['maxGuests'] as num).toInt(),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$EventMenuImplToJson(_$EventMenuImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'pricePerPerson': instance.pricePerPerson,
      'minGuests': instance.minGuests,
      'maxGuests': instance.maxGuests,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

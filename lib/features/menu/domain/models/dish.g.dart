// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DishImpl _$$DishImplFromJson(Map<String, dynamic> json) => _$DishImpl(
  id: json['id'] as String,
  categoryId: json['category_id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  description: json['description'] as String? ?? '',
  imageUrl: json['image_url'] as String?,
  allergens:
      (json['allergens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  prepTimeMin: (json['prep_time_min'] as num?)?.toInt() ?? 15,
  isAvailable: json['is_available'] as bool? ?? true,
  isActive: json['is_active'] as bool? ?? true,
  isOffer: json['is_offer'] as bool? ?? false,
  isSeasonal: json['is_seasonal'] as bool? ?? false,
  offerPrice: (json['offer_price'] as num?)?.toDouble(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$DishImplToJson(_$DishImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'allergens': instance.allergens,
      'prep_time_min': instance.prepTimeMin,
      'is_available': instance.isAvailable,
      'is_active': instance.isActive,
      'is_offer': instance.isOffer,
      'is_seasonal': instance.isSeasonal,
      'offer_price': instance.offerPrice,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

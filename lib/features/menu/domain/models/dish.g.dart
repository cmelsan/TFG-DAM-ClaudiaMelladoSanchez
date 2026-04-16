// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dish _$DishFromJson(Map<String, dynamic> json) => Dish(
  id: json['id'] as String,
  categoryId: json['category_id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  description: json['description'] as String,
  imageUrl: json['image_url'] as String?,
  allergens: (json['allergens'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  prepTimeMin: (json['prep_time_min'] as num).toInt(),
  isAvailable: json['is_available'] as bool,
  isActive: json['is_active'] as bool,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$DishToJson(Dish instance) => <String, dynamic>{
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
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

_$DishImpl _$$DishImplFromJson(Map<String, dynamic> json) => _$DishImpl(
  id: json['id'] as String,
  categoryId: json['categoryId'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  description: json['description'] as String? ?? '',
  imageUrl: json['imageUrl'] as String?,
  allergens:
      (json['allergens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  prepTimeMin: (json['prepTimeMin'] as num?)?.toInt() ?? 15,
  isAvailable: json['isAvailable'] as bool? ?? true,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$DishImplToJson(_$DishImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'allergens': instance.allergens,
      'prepTimeMin': instance.prepTimeMin,
      'isAvailable': instance.isAvailable,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartItemImpl _$$CartItemImplFromJson(Map<String, dynamic> json) =>
    _$CartItemImpl(
      dishId: json['dish_id'] as String,
      name: json['name'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
      allergens:
          (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isAvailable: json['is_available'] as bool? ?? true,
      prepTimeMin: (json['prep_time_min'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CartItemImplToJson(_$CartItemImpl instance) =>
    <String, dynamic>{
      'dish_id': instance.dishId,
      'name': instance.name,
      'unit_price': instance.unitPrice,
      'quantity': instance.quantity,
      'image_url': instance.imageUrl,
      'allergens': instance.allergens,
      'is_available': instance.isAvailable,
      'prep_time_min': instance.prepTimeMin,
    };

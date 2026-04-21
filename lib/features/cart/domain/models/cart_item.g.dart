// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
  dishId: json['dish_id'] as String,
  name: json['name'] as String,
  unitPrice: (json['unit_price'] as num).toDouble(),
  quantity: (json['quantity'] as num).toInt(),
  imageUrl: json['image_url'] as String?,
  allergens: (json['allergens'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isAvailable: json['is_available'] as bool,
  prepTimeMin: (json['prep_time_min'] as num).toInt(),
);

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
  'dish_id': instance.dishId,
  'name': instance.name,
  'unit_price': instance.unitPrice,
  'quantity': instance.quantity,
  'image_url': instance.imageUrl,
  'allergens': instance.allergens,
  'is_available': instance.isAvailable,
  'prep_time_min': instance.prepTimeMin,
};

_$CartItemImpl _$$CartItemImplFromJson(Map<String, dynamic> json) =>
    _$CartItemImpl(
      dishId: json['dishId'] as String,
      name: json['name'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      allergens:
          (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isAvailable: json['isAvailable'] as bool? ?? true,
      prepTimeMin: (json['prepTimeMin'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CartItemImplToJson(_$CartItemImpl instance) =>
    <String, dynamic>{
      'dishId': instance.dishId,
      'name': instance.name,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
      'imageUrl': instance.imageUrl,
      'allergens': instance.allergens,
      'isAvailable': instance.isAvailable,
      'prepTimeMin': instance.prepTimeMin,
    };

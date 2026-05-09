// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_special.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailySpecialImpl _$$DailySpecialImplFromJson(Map<String, dynamic> json) =>
    _$DailySpecialImpl(
      id: json['id'] as String,
      dishId: json['dish_id'] as String,
      date: DateTime.parse(json['date'] as String),
      discountPercent: (json['discount_percent'] as num?)?.toInt(),
      note: json['note'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      primeroText: json['primero_text'] as String?,
      segundoText: json['segundo_text'] as String?,
      postreText: json['postre_text'] as String?,
      bebidaText: json['bebida_text'] as String?,
      menuPrice: (json['menu_price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$DailySpecialImplToJson(_$DailySpecialImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dish_id': instance.dishId,
      'date': instance.date.toIso8601String(),
      'discount_percent': instance.discountPercent,
      'note': instance.note,
      'created_at': instance.createdAt?.toIso8601String(),
      'primero_text': instance.primeroText,
      'segundo_text': instance.segundoText,
      'postre_text': instance.postreText,
      'bebida_text': instance.bebidaText,
      'menu_price': instance.menuPrice,
    };

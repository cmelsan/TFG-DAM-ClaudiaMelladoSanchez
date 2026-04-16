// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_special.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailySpecial _$DailySpecialFromJson(Map<String, dynamic> json) => DailySpecial(
  id: json['id'] as String,
  dishId: json['dish_id'] as String,
  date: DateTime.parse(json['date'] as String),
  discountPercent: (json['discount_percent'] as num?)?.toInt(),
  note: json['note'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$DailySpecialToJson(DailySpecial instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dish_id': instance.dishId,
      'date': instance.date.toIso8601String(),
      'discount_percent': instance.discountPercent,
      'note': instance.note,
      'created_at': instance.createdAt?.toIso8601String(),
    };

_$DailySpecialImpl _$$DailySpecialImplFromJson(Map<String, dynamic> json) =>
    _$DailySpecialImpl(
      id: json['id'] as String,
      dishId: json['dishId'] as String,
      date: DateTime.parse(json['date'] as String),
      discountPercent: (json['discountPercent'] as num?)?.toInt(),
      note: json['note'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DailySpecialImplToJson(_$DailySpecialImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dishId': instance.dishId,
      'date': instance.date.toIso8601String(),
      'discountPercent': instance.discountPercent,
      'note': instance.note,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

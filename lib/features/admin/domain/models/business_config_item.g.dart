// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_config_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessConfigItem _$BusinessConfigItemFromJson(Map<String, dynamic> json) =>
    BusinessConfigItem(
      id: json['id'] as String,
      key: json['key'] as String,
      value: json['value'] as String,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BusinessConfigItemToJson(BusinessConfigItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$BusinessConfigItemImpl _$$BusinessConfigItemImplFromJson(
  Map<String, dynamic> json,
) => _$BusinessConfigItemImpl(
  id: json['id'] as String,
  key: json['key'] as String,
  value: json['value'] as String,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$BusinessConfigItemImplToJson(
  _$BusinessConfigItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'key': instance.key,
  'value': instance.value,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

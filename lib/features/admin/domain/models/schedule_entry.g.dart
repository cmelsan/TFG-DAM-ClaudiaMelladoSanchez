// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleEntryImpl _$$ScheduleEntryImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleEntryImpl(
      id: json['id'] as String,
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      openTime: json['open_time'] as String,
      closeTime: json['close_time'] as String,
      isOpen: json['is_open'] as bool,
    );

Map<String, dynamic> _$$ScheduleEntryImplToJson(_$ScheduleEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day_of_week': instance.dayOfWeek,
      'open_time': instance.openTime,
      'close_time': instance.closeTime,
      'is_open': instance.isOpen,
    };

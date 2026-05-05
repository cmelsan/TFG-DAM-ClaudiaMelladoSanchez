// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_event_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminEventRequestImpl _$$AdminEventRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AdminEventRequestImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  eventDate: DateTime.parse(json['event_date'] as String),
  guestCount: (json['guest_count'] as num).toInt(),
  location: json['location'] as String,
  status: json['status'] as String,
  notes: json['notes'] as String?,
  quotedTotal: (json['quoted_total'] as num?)?.toDouble(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$AdminEventRequestImplToJson(
  _$AdminEventRequestImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'event_date': instance.eventDate.toIso8601String(),
  'guest_count': instance.guestCount,
  'location': instance.location,
  'status': instance.status,
  'notes': instance.notes,
  'quoted_total': instance.quotedTotal,
  'created_at': instance.createdAt?.toIso8601String(),
};

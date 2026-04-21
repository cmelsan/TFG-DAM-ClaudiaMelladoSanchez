// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_event_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminEventRequest _$AdminEventRequestFromJson(Map<String, dynamic> json) =>
    AdminEventRequest(
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

Map<String, dynamic> _$AdminEventRequestToJson(AdminEventRequest instance) =>
    <String, dynamic>{
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

_$AdminEventRequestImpl _$$AdminEventRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AdminEventRequestImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  eventDate: DateTime.parse(json['eventDate'] as String),
  guestCount: (json['guestCount'] as num).toInt(),
  location: json['location'] as String,
  status: json['status'] as String,
  notes: json['notes'] as String?,
  quotedTotal: (json['quotedTotal'] as num?)?.toDouble(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$AdminEventRequestImplToJson(
  _$AdminEventRequestImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'eventDate': instance.eventDate.toIso8601String(),
  'guestCount': instance.guestCount,
  'location': instance.location,
  'status': instance.status,
  'notes': instance.notes,
  'quotedTotal': instance.quotedTotal,
  'createdAt': instance.createdAt?.toIso8601String(),
};

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
  eventMenuId: json['event_menu_id'] as String?,
  eventMenuName: json['event_menu_name'] as String?,
  eventMenuPricePerPerson: (json['event_menu_price_per_person'] as num?)
      ?.toDouble(),
  eventType: json['event_type'] as String?,
  contactPhone: json['contact_phone'] as String?,
  menuType: json['menu_type'] as String?,
  customMenuDescription: json['custom_menu_description'] as String?,
  notes: json['notes'] as String?,
  quotedTotal: (json['quoted_total'] as num?)?.toDouble(),
  adminNotes: json['admin_notes'] as String?,
  appointmentAt: json['appointment_at'] == null
      ? null
      : DateTime.parse(json['appointment_at'] as String),
  appointmentNotes: json['appointment_notes'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  displayId: json['display_id'] as String?,
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
  'event_menu_id': instance.eventMenuId,
  'event_menu_name': instance.eventMenuName,
  'event_menu_price_per_person': instance.eventMenuPricePerPerson,
  'event_type': instance.eventType,
  'contact_phone': instance.contactPhone,
  'menu_type': instance.menuType,
  'custom_menu_description': instance.customMenuDescription,
  'notes': instance.notes,
  'quoted_total': instance.quotedTotal,
  'admin_notes': instance.adminNotes,
  'appointment_at': instance.appointmentAt?.toIso8601String(),
  'appointment_notes': instance.appointmentNotes,
  'created_at': instance.createdAt?.toIso8601String(),
  'display_id': instance.displayId,
};

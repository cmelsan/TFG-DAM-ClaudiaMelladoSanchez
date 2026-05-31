// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SupportThreadImpl _$$SupportThreadImplFromJson(Map<String, dynamic> json) =>
    _$SupportThreadImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subject: json['subject'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      unreadForAdmin: (json['unread_for_admin'] as num).toInt(),
      unreadForCustomer: (json['unread_for_customer'] as num).toInt(),
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      lastMessage: json['last_message'] as String?,
      userFullName: json['user_full_name'] as String?,
      userEmail: json['user_email'] as String?,
    );

Map<String, dynamic> _$$SupportThreadImplToJson(_$SupportThreadImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'subject': instance.subject,
      'category': instance.category,
      'status': instance.status,
      'unread_for_admin': instance.unreadForAdmin,
      'unread_for_customer': instance.unreadForCustomer,
      'last_message_at': instance.lastMessageAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'last_message': instance.lastMessage,
      'user_full_name': instance.userFullName,
      'user_email': instance.userEmail,
    };

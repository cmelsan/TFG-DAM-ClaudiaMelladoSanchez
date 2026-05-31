// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SupportMessageImpl _$$SupportMessageImplFromJson(Map<String, dynamic> json) =>
    _$SupportMessageImpl(
      id: json['id'] as String,
      threadId: json['thread_id'] as String,
      senderId: json['sender_id'] as String,
      senderRole: json['sender_role'] as String,
      body: json['body'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$SupportMessageImplToJson(
  _$SupportMessageImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'thread_id': instance.threadId,
  'sender_id': instance.senderId,
  'sender_role': instance.senderRole,
  'body': instance.body,
  'created_at': instance.createdAt?.toIso8601String(),
};

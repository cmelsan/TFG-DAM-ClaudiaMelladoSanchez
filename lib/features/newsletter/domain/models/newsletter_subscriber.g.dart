// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newsletter_subscriber.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsletterSubscriberImpl _$$NewsletterSubscriberImplFromJson(
  Map<String, dynamic> json,
) => _$NewsletterSubscriberImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  status: json['status'] as String,
  source: json['source'] as String,
  locale: json['locale'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  fullName: json['full_name'] as String?,
  userId: json['user_id'] as String?,
  unsubscribedAt: json['unsubscribed_at'] == null
      ? null
      : DateTime.parse(json['unsubscribed_at'] as String),
);

Map<String, dynamic> _$$NewsletterSubscriberImplToJson(
  _$NewsletterSubscriberImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'status': instance.status,
  'source': instance.source,
  'locale': instance.locale,
  'created_at': instance.createdAt.toIso8601String(),
  'full_name': instance.fullName,
  'user_id': instance.userId,
  'unsubscribed_at': instance.unsubscribedAt?.toIso8601String(),
};

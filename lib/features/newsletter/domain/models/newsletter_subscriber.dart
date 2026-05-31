import 'package:freezed_annotation/freezed_annotation.dart';

part 'newsletter_subscriber.freezed.dart';
part 'newsletter_subscriber.g.dart';

@freezed
class NewsletterSubscriber with _$NewsletterSubscriber {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory NewsletterSubscriber({
    required String id,
    required String email,
    required String status, // active | unsubscribed | bounced
    required String source, // web | admin | api | …
    required String locale,
    required DateTime createdAt,
    String? fullName,
    String? userId,
    DateTime? unsubscribedAt,
  }) = _NewsletterSubscriber;

  factory NewsletterSubscriber.fromJson(Map<String, dynamic> json) =>
      _$NewsletterSubscriberFromJson(json);
}

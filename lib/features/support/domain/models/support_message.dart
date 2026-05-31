import 'package:freezed_annotation/freezed_annotation.dart';

part 'support_message.freezed.dart';
part 'support_message.g.dart';

@freezed
class SupportMessage with _$SupportMessage {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SupportMessage({
    required String id,
    required String threadId,
    required String senderId,
    required String senderRole,
    required String body,
    DateTime? createdAt,
  }) = _SupportMessage;

  factory SupportMessage.fromJson(Map<String, dynamic> json) =>
      _$SupportMessageFromJson(json);
}

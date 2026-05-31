import 'package:freezed_annotation/freezed_annotation.dart';

part 'support_thread.freezed.dart';
part 'support_thread.g.dart';

@freezed
class SupportThread with _$SupportThread {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SupportThread({
    required String id,
    required String userId,
    required String subject,
    required String category,
    required String status,
    required int unreadForAdmin,
    required int unreadForCustomer,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessage,
    String? userFullName,
    String? userEmail,
  }) = _SupportThread;

  factory SupportThread.fromJson(Map<String, dynamic> json) =>
      _$SupportThreadFromJson(json);

  factory SupportThread.fromSupabaseJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    final profileMap = profile is Map<String, dynamic> ? profile : null;
    return SupportThread.fromJson({
      ...json,
      if (profileMap != null) ...{
        'user_full_name': profileMap['full_name'],
        'user_email': profileMap['email'],
      },
    });
  }
}

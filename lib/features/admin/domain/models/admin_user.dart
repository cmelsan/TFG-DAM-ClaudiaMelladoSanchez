import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_user.freezed.dart';
part 'admin_user.g.dart';

@freezed
class AdminUser with _$AdminUser {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AdminUser({
    required String id,
    required String email,
    required String role,
    required bool isActive,
    String? fullName,
    String? phone,
    DateTime? createdAt,
  }) = _AdminUser;

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);
}

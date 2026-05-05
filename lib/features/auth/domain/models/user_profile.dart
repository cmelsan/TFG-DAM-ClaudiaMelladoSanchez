import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Rol del usuario en la aplicación.
enum UserRole {
  @JsonValue('client')
  client,
  @JsonValue('employee')
  employee,
  @JsonValue('admin')
  admin,
}

/// Modelo correspondiente a la tabla `profiles` de Supabase.
@freezed
class UserProfile with _$UserProfile {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserProfile({
    required String id,
    required String email,
    @Default(UserRole.client) UserRole role,
    String? fullName,
    String? phone,
    String? avatarUrl,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

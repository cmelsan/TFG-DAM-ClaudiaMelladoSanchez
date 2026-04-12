// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: json['id'] as String,
  email: json['email'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  fullName: json['full_name'] as String?,
  phone: json['phone'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  isActive: json['is_active'] as bool,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'avatar_url': instance.avatarUrl,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.client: 'client',
  UserRole.employee: 'employee',
  UserRole.admin: 'admin',
};

_$UserProfileImpl _$$UserProfileImplFromJson(
  Map<String, dynamic> json,
) => _$UserProfileImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.client,
  fullName: json['fullName'] as String?,
  phone: json['phone'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'avatarUrl': instance.avatarUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

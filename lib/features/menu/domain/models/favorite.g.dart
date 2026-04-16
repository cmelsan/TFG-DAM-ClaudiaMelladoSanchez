// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Favorite _$FavoriteFromJson(Map<String, dynamic> json) => Favorite(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  dishId: json['dish_id'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$FavoriteToJson(Favorite instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'dish_id': instance.dishId,
  'created_at': instance.createdAt?.toIso8601String(),
};

_$FavoriteImpl _$$FavoriteImplFromJson(Map<String, dynamic> json) =>
    _$FavoriteImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      dishId: json['dishId'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$FavoriteImplToJson(_$FavoriteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'dishId': instance.dishId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

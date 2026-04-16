import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite.freezed.dart';
part 'favorite.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
class Favorite with _$Favorite {
  const factory Favorite({
    required String id,
    required String userId,
    required String dishId,
    DateTime? createdAt,
  }) = _Favorite;

  factory Favorite.fromJson(Map<String, dynamic> json) =>
      _$FavoriteFromJson(json);
}

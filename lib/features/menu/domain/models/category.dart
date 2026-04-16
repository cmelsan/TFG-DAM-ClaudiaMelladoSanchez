import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    String? description,
    String? imageUrl,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

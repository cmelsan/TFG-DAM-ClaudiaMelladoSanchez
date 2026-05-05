import 'package:freezed_annotation/freezed_annotation.dart';

part 'dish.freezed.dart';
part 'dish.g.dart';

@freezed
class Dish with _$Dish {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Dish({
    required String id,
    required String categoryId,
    required String name,
    required double price,
    @Default('') String description,
    String? imageUrl,
    @Default([]) List<String> allergens,
    @Default(15) int prepTimeMin,
    @Default(true) bool isAvailable,
    @Default(true) bool isActive,
    @Default(false) bool isOffer,
    @Default(false) bool isSeasonal,
    double? offerPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Dish;

  factory Dish.fromJson(Map<String, dynamic> json) => _$DishFromJson(json);
}

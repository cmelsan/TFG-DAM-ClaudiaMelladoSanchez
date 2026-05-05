import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_special.freezed.dart';
part 'daily_special.g.dart';

@freezed
class DailySpecial with _$DailySpecial {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory DailySpecial({
    required String id,
    required String dishId,
    required DateTime date,
    int? discountPercent,
    String? note,
    DateTime? createdAt,
  }) = _DailySpecial;

  factory DailySpecial.fromJson(Map<String, dynamic> json) =>
      _$DailySpecialFromJson(json);
}

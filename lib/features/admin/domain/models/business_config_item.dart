import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_config_item.freezed.dart';
part 'business_config_item.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
class BusinessConfigItem with _$BusinessConfigItem {
  const factory BusinessConfigItem({
    required String id,
    required String key,
    required String value,
    DateTime? updatedAt,
  }) = _BusinessConfigItem;

  factory BusinessConfigItem.fromJson(Map<String, dynamic> json) =>
      _$BusinessConfigItemFromJson(json);
}

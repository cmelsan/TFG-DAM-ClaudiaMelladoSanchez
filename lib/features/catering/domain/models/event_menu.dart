import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_menu.freezed.dart';
part 'event_menu.g.dart';

@freezed
class EventMenu with _$EventMenu {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory EventMenu({
    required String id,
    required String name,
    required double pricePerPerson,
    required int minGuests,
    required int maxGuests,
    String? description,
    String? imageUrl,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _EventMenu;

  factory EventMenu.fromJson(Map<String, dynamic> json) =>
      _$EventMenuFromJson(json);
}

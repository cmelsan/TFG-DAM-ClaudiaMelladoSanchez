import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_entry.freezed.dart';
part 'schedule_entry.g.dart';

@freezed
class ScheduleEntry with _$ScheduleEntry {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ScheduleEntry({
    required String id,
    required int dayOfWeek,
    required String openTime,
    required String closeTime,
    required bool isOpen,
  }) = _ScheduleEntry;

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) =>
      _$ScheduleEntryFromJson(json);
}

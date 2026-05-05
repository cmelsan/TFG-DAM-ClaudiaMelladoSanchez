import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_event_request.freezed.dart';
part 'admin_event_request.g.dart';

@freezed
class AdminEventRequest with _$AdminEventRequest {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AdminEventRequest({
    required String id,
    required String userId,
    required DateTime eventDate,
    required int guestCount,
    required String location,
    required String status,
    String? notes,
    double? quotedTotal,
    DateTime? createdAt,
  }) = _AdminEventRequest;

  factory AdminEventRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminEventRequestFromJson(json);
}

import 'package:sabor_de_casa/features/admin/domain/models/admin_event_request.dart';

extension EventRequestShortId on AdminEventRequest {
  String get shortId => displayId ?? 'CAT-${id.substring(0, 4).toUpperCase()}';
}

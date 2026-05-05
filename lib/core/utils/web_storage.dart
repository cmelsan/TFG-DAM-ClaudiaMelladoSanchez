/// Abstracción de sessionStorage/location para web.
/// En plataformas no-web (Android/iOS), todas las operaciones son no-ops.
library;

export 'web_storage_stub.dart' if (dart.library.html) 'web_storage_web.dart';

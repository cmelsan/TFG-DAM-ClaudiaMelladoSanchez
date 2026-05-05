/// Stub para plataformas no-web (Android, iOS, desktop).
/// Todas las operaciones son no-ops seguros.
class WebStorage {
  WebStorage._();
  static void setItem(String key, String value) {}
  static String? getItem(String key) => null;
  static void removeItem(String key) {}
  static void redirectTo(String url) {}
  static String get currentOrigin => '';
}

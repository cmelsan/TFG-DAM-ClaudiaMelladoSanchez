import 'package:web/web.dart' as web;

/// Implementación web de WebStorage usando sessionStorage del navegador.
/// Se exporta condicionalmente desde web_storage.dart.
class WebStorage {
  WebStorage._();

  static void setItem(String key, String value) =>
      web.window.sessionStorage.setItem(key, value);

  static String? getItem(String key) {
    final value = web.window.sessionStorage.getItem(key);
    return (value?.isNotEmpty ?? false) ? value : null;
  }

  static void removeItem(String key) =>
      web.window.sessionStorage.removeItem(key);

  /// Redirige la pestaña actual a [url] (navegación completa).
  // ignore: use_setters_to_change_properties
  static void redirectTo(String url) => web.window.location.href = url;

  /// Devuelve el origen actual (ej. 'http://localhost:63760').
  static String get currentOrigin => web.window.location.origin;
}

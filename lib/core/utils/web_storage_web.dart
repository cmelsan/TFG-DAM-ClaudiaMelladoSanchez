// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Implementación web de WebStorage usando sessionStorage del navegador.
/// Se exporta condicionalmente desde web_storage.dart.
class WebStorage {
  WebStorage._();

  static void setItem(String key, String value) =>
      html.window.sessionStorage[key] = value;

  static String? getItem(String key) => html.window.sessionStorage[key];

  static void removeItem(String key) => html.window.sessionStorage.remove(key);

  /// Redirige la pestaña actual a [url] (navegación completa).
  // ignore: use_setters_to_change_properties
  static void redirectTo(String url) => html.window.location.href = url;

  /// Devuelve el origen actual (ej. 'http://localhost:63760').
  static String get currentOrigin => html.window.location.origin;
}

/// Configuración de entorno con --dart-define-from-file.
/// Los valores se compilan en el binario (no aparecen como texto plano).
class EnvConfig {
  const EnvConfig._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}

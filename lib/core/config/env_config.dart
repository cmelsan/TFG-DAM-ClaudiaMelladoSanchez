/// Configuración de entorno.
/// ESTE ARCHIVO ESTÁ EN .gitignore — no se sube al repositorio.
/// Para colaboradores: copia env_config.dart.example y rellena los valores.
class EnvConfig {
  const EnvConfig._();

  // ignore: do_not_use_environment
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://vrxliepwzvdrcxpdgpnd.supabase.co',
  );

  // ignore: do_not_use_environment
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZyeGxpZXB3enZkcmN4cGRncG5kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwMTcxOTMsImV4cCI6MjA5MTU5MzE5M30.hcIMyZFcioTHc8Yvl1lN8kQ0CfouPpg2zuOA3KJgFGQ',
  );

  // ignore: do_not_use_environment
  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51TRTQBExComtisIRHgklbU3nuH2xgQGEFaAdg4yFTtG6HeqOdfS5lrJmQNup9MZDZX8hYW9w9ZqDHF3ewHbCwLLJ00PfbEgzdi',
  );
}

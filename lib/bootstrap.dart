import 'package:sabor_de_casa/core/config/env_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Inicializa los servicios necesarios antes de runApp.
Future<void> bootstrap() async {
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );
}

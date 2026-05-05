import 'package:sabor_de_casa/core/config/env_config.dart';
import 'package:sabor_de_casa/core/constants/supabase_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  final client = Supabase.instance.client;
  print('Initialized, querying dishes...');

  try {
    final response = await client.from(SupabaseConstants.dishes).select();
    print('Response: $response');
  } catch (e, st) {
    print('ERROR direct: $e');
    print(st);
  }

  print('DONE.');
}

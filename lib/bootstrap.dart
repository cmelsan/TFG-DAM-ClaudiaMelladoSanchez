import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sabor_de_casa/core/config/env_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Inicializa los servicios necesarios antes de runApp.
Future<void> bootstrap() async {
  if (EnvConfig.supabaseUrl.isEmpty || EnvConfig.supabaseAnonKey.isEmpty) {
    throw StateError(
      '[bootstrap] Credenciales de Supabase vacías.\n'
      'Ejecuta la app con:\n'
      '  flutter run --dart-define-from-file=.env.development\n'
      'O usa la configuración de Run & Debug en VS Code.',
    );
  }

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
    debug: kDebugMode,
  );

  // flutter_stripe usa dart:io internamente y stripe_web (su implementación web)
  // no es compatible con Dart 3.x → solo inicializar en plataformas nativas.
  // En web, el pago usa Stripe Checkout (redirect) via la Edge Function.
  if (!kIsWeb) {
    try {
      Stripe.publishableKey = EnvConfig.stripePublishableKey;
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint('[bootstrap] Stripe no disponible: $e');
    }
  }
}

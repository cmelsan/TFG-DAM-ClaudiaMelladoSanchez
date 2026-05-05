import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

    // Firebase Messaging (solo Android/iOS; en web las notificaciones son email)
    try {
      await Firebase.initializeApp();
      await _setupFcm();
    } catch (e) {
      // No interrumpir el arranque si Firebase no está configurado
      debugPrint('[bootstrap] Firebase no disponible: $e');
    }
  }
}

/// Solicita permisos de notificación y registra el token FCM en Supabase.
Future<void> _setupFcm() async {
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    debugPrint('[FCM] Notificaciones denegadas por el usuario');
    return;
  }

  final token = await messaging.getToken();
  if (token != null) {
    await _saveFcmToken(token);
  }

  // Actualizar token si cambia (raro, pero puede ocurrir)
  messaging.onTokenRefresh.listen(_saveFcmToken);
}

Future<void> _saveFcmToken(String token) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;
  if (userId == null) return;

  // Upsert en push_tokens (user_id + token como clave única)
  await client
      .from('push_tokens')
      .upsert({
        'user_id': userId,
        'token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,token')
      .catchError((Object e) => debugPrint('[FCM] Error guardando token: $e'));
}

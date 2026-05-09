import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'subscription_provider.g.dart';

/// Estado de la suscripción actual (idle / loading / done / error).
enum SubscriptionStatus { idle, loading, done, error }

/// Notifier para gestionar las suscripciones de newsletter / WhatsApp.
@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  SubscriptionStatus build() => SubscriptionStatus.idle;

  /// Inserta una suscripción en Supabase.
  /// [type] debe ser 'email' o 'whatsapp'.
  Future<void> subscribe({
    required String type,
    String? email,
    String? phone,
  }) async {
    assert(
      (type == 'email' && email != null) ||
          (type == 'whatsapp' && phone != null),
      'email requerido para type=email; phone para type=whatsapp',
    );

    state = SubscriptionStatus.loading;
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('subscriptions').insert({
        'type': type,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      });
      state = SubscriptionStatus.done;
    } on PostgrestException catch (_) {
      state = SubscriptionStatus.error;
    } catch (_) {
      state = SubscriptionStatus.error;
    }
  }

  void reset() => state = SubscriptionStatus.idle;
}

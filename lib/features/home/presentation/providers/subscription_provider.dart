import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/home/data/repositories/subscription_repository.dart';

part 'subscription_provider.g.dart';

/// Estado de la suscripciÃ³n actual (idle / loading / done / error).
enum SubscriptionStatus { idle, loading, done, error }

/// Notifier para gestionar las suscripciones de newsletter / WhatsApp.
@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  SubscriptionStatus build() => SubscriptionStatus.idle;

  /// Inserta una suscripciÃ³n en Supabase via SubscriptionRepository.
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
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.subscribe(type: type, email: email, phone: phone);
      state = SubscriptionStatus.done;
    } catch (_) {
      state = SubscriptionStatus.error;
    }
  }

  void reset() => state = SubscriptionStatus.idle;
}

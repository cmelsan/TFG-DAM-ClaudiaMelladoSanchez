import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/home/data/repositories/subscription_repository.dart';

part 'subscription_provider.g.dart';

/// Estado de la suscripciÃ³n actual (idle / loading / done / error).
enum SubscriptionStatus { idle, loading, done, duplicate, error }

/// Notifier para gestionar las suscripciones de newsletter / WhatsApp.
@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  SubscriptionStatus build() => SubscriptionStatus.idle;

  /// Inserta suscripcion email en newsletter_subscribers.
  Future<void> subscribe({
    required String email,
  }) async {
    state = SubscriptionStatus.loading;
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.subscribe(type: 'email', email: email);
      state = SubscriptionStatus.done;
    } on DatabaseFailure catch (e) {
      if (e.code == 'duplicate_email') {
        state = SubscriptionStatus.duplicate;
      } else {
        state = SubscriptionStatus.error;
      }
    } catch (_) {
      state = SubscriptionStatus.error;
    }
  }

  void reset() => state = SubscriptionStatus.idle;
}

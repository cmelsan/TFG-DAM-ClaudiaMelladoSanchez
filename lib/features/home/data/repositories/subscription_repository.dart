import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'subscription_repository.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
SubscriptionRepository subscriptionRepository(SubscriptionRepositoryRef ref) {
  return SubscriptionRepository(ref.watch(supabaseClientProvider));
}

class SubscriptionRepository {
  SubscriptionRepository(this._client);

  final SupabaseClient _client;

  /// Inserta una nueva suscripción de newsletter o WhatsApp.
  /// [type] debe ser 'email' o 'whatsapp'.
  Future<void> subscribe({
    required String type,
    String? email,
    String? phone,
  }) async {
    try {
      await _client.from('subscriptions').insert({
        'type': type,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      });
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/notifications/domain/models/app_notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notifications_repository.g.dart';

@riverpod
NotificationsRepository notificationsRepository(
  NotificationsRepositoryRef ref, // ignore: deprecated_member_use_from_same_package
) =>
    NotificationsRepository(Supabase.instance.client);

class NotificationsRepository {
  const NotificationsRepository(this._client);
  final SupabaseClient _client;

  /// Obtiene las últimas 50 notificaciones del usuario autenticado.
  Future<List<AppNotification>> fetchAll() async {
    final data = await _client
        .from('notifications')
        .select()
        .order('created_at', ascending: false)
        .limit(50);

    return (data as List)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Marca una notificación como leída.
  Future<void> markAsRead(String id) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  /// Marca todas las notificaciones del usuario como leídas.
  Future<void> markAllAsRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  /// Inserta una notificación local (desde FCM foreground).
  Future<void> insertLocal({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      if (data != null) 'data': data,
    });
  }
}

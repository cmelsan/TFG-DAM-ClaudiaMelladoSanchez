import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/notifications/data/repositories/notifications_repository.dart';
import 'package:sabor_de_casa/features/notifications/domain/models/app_notification.dart';

part 'notifications_provider.g.dart';

/// Estado de la lista de notificaciones.
@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  Future<List<AppNotification>> build() async {
    return ref.read(notificationsRepositoryProvider).fetchAll();
  }

  /// Refresca la lista desde Supabase.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationsRepositoryProvider).fetchAll(),
    );
  }

  /// Marca una notificación como leída localmente y en Supabase.
  Future<void> markAsRead(String id) async {
    await ref.read(notificationsRepositoryProvider).markAsRead(id);
    state = state.whenData(
      (list) => list
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList(),
    );
  }

  /// Marca todas como leídas.
  Future<void> markAllAsRead() async {
    await ref.read(notificationsRepositoryProvider).markAllAsRead();
    state = state.whenData(
      (list) => list.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }
}

/// Número de notificaciones no leídas (para el badge en la campana).
@riverpod
// ignore: deprecated_member_use_from_same_package
int unreadNotificationsCount(UnreadNotificationsCountRef ref) {
  final notificationsAsync = ref.watch(notificationsNotifierProvider);
  return notificationsAsync.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
}

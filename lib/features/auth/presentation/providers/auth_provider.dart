import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/auth/data/repositories/auth_repository.dart';
import 'package:sabor_de_casa/features/auth/domain/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

/// Estado de autenticación global.
/// - AsyncLoading  → comprobando sesión
/// - AsyncData(null) → no autenticado
/// - AsyncData(UserProfile) → autenticado
/// - AsyncError → error al comprobar sesión
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  late final AuthRepository _repo;

  /// Evita que el stream interfiera mientras signIn/signUp están en curso.
  bool _isAuthOperationInProgress = false;

  @override
  FutureOr<UserProfile?> build() async {
    // ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
    _repo = ref.watch(authRepositoryProvider);

    // Escuchar cambios de auth (token refresh, logout, etc.)
    // Ignoramos signedIn durante operaciones explícitas para evitar condición de carrera.
    final sub = _repo.watchAuthState().listen((event) {
      switch (event.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          if (!_isAuthOperationInProgress) _refreshProfile();
          // Registrar token FCM tras autenticación (solo nativo)
          if (!kIsWeb) _saveFcmToken();
        case AuthChangeEvent.signedOut:
          state = const AsyncData(null);
        case _:
          break;
      }
    });
    ref.onDispose(sub.cancel);

    // Comprobar sesión existente al arrancar (persistencia entre recargas)
    if (_repo.currentSession != null) {
      return _repo.getProfile();
    }
    return null;
  }

  Future<void> signIn({required String email, required String password}) async {
    _isAuthOperationInProgress = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signIn(email: email, password: password),
    );
    _isAuthOperationInProgress = false;
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    _isAuthOperationInProgress = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      ),
    );
    _isAuthOperationInProgress = false;
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncData(null);
  }

  Future<void> _refreshProfile() async {
    state = await AsyncValue.guard(() => _repo.getProfile());
  }

  /// Registra el token FCM del dispositivo en push_tokens (best-effort).
  Future<void> _saveFcmToken() async {
    try {
      final userId = _repo.currentUser?.id;
      if (userId == null) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await Supabase.instance.client.from('push_tokens').upsert({
        'user_id': userId,
        'token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,token');
    } catch (e) {
      debugPrint('[FCM] Error guardando token: $e');
    }
  }
}

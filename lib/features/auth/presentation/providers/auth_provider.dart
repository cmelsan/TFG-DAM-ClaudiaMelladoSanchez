import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/auth/data/repositories/auth_repository.dart';
import 'package:sabor_de_casa/features/auth/domain/models/user_profile.dart';
import 'package:sabor_de_casa/features/auth/presentation/providers/password_recovery_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

/// Estado de autenticación global.
/// - AsyncLoading  → comprobando sesión
/// - AsyncData(null) → no autenticado
/// - AsyncData(UserProfile) → autenticado
/// - AsyncError → error al comprobar sesión
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  AuthRepository? _repo;

  /// Evita que el stream interfiera mientras signIn/signUp están en curso.
  bool _isAuthOperationInProgress = false;

  Future<UserProfile?> _loadProfileOrNull() async {
    try {
      return await _repo!.getProfile();
    } on AuthFailure {
      return null;
    }
  }

  @override
  FutureOr<UserProfile?> build() async {
    // ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
    _repo ??= ref.watch(authRepositoryProvider);

    // Escuchar cambios de auth (token refresh, logout, etc.)
    // Ignoramos signedIn durante operaciones explícitas para evitar condición de carrera.
    final sub = _repo!.watchAuthState().listen((event) {
      switch (event.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          if (!_isAuthOperationInProgress) _refreshProfile();
        case AuthChangeEvent.passwordRecovery:
          // El usuario llegó desde el enlace de recuperación de contraseña.
          // Activar modo recuperación para que el router redirija a /auth/reset-password.
          ref.read(passwordRecoveryModeProvider.notifier).state = true;
          _refreshProfile();
        case AuthChangeEvent.signedOut:
          state = const AsyncData(null);
        case _:
          break;
      }
    });
    ref.onDispose(sub.cancel);

    // Comprobar sesión existente al arrancar (persistencia entre recargas)
    if (_repo!.currentSession != null) return _loadProfileOrNull();
    return null;
  }

  Future<void> signIn({required String email, required String password}) async {
    _isAuthOperationInProgress = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo!.signIn(email: email, password: password),
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
      () => _repo!.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      ),
    );
    _isAuthOperationInProgress = false;
  }

  Future<void> signOut() async {
    await _repo!.signOut();
    state = const AsyncData(null);
  }

  Future<void> _refreshProfile() async {
    state = const AsyncLoading();
    final profile = await _loadProfileOrNull();
    state = AsyncData(profile);
  }
}

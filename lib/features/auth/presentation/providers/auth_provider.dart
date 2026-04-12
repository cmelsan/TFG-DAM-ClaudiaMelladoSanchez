import 'dart:async';

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

  @override
  FutureOr<UserProfile?> build() async {
    // ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
    _repo = ref.watch(authRepositoryProvider);

    // Escuchar cambios de auth (login, logout, token refresh)
    final sub = _repo.watchAuthState().listen((event) {
      switch (event.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          _refreshProfile();
        case AuthChangeEvent.signedOut:
          state = const AsyncData(null);
        case _:
          break;
      }
    });
    ref.onDispose(sub.cancel);

    // Comprobar sesión existente
    if (_repo.currentSession != null) {
      return _repo.getProfile();
    }
    return null;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signIn(email: email, password: password),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      ),
    );
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncData(null);
  }

  Future<void> _refreshProfile() async {
    state = await AsyncValue.guard(() => _repo.getProfile());
  }
}

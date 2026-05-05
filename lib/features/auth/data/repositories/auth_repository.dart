import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/constants/supabase_constants.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/auth/domain/models/user_profile.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
}

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Stream que emite cambios en el estado de autenticación.
  Stream<AuthState> watchAuthState() => _client.auth.onAuthStateChange;

  /// Sesión actual (null si no hay).
  Session? get currentSession => _client.auth.currentSession;

  /// Usuario autenticado actual (null si no hay).
  User? get currentUser => _client.auth.currentUser;

  /// Iniciar sesión con email y contraseña.
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return _fetchProfile();
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Registrarse con email y contraseña + datos de perfil.
  /// Requiere que en Supabase → Auth → Settings esté desactivado "Confirm email".
  Future<UserProfile> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone': phone,
        },
      );

      // Si no hay sesión, Supabase requiere confirmación de email.
      // En ese caso no podemos continuar sin que el usuario confirme.
      if (response.session == null) {
        throw const AuthFailure(
          message:
              'Revisa tu correo y confirma tu cuenta para poder iniciar sesión.',
        );
      }

      // Esperar a que el trigger handle_new_user cree la fila en profiles.
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Actualizar full_name y phone si los proporcionaron.
      final user = response.user;
      if (user != null && (fullName != null || phone != null)) {
        await _client
            .from(SupabaseConstants.profiles)
            .update({
              if (fullName != null) 'full_name': fullName,
              if (phone != null) 'phone': phone,
            })
            .eq('id', user.id);
      }
      return _fetchProfile();
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Cerrar sesión.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Obtiene el perfil del usuario autenticado actual.
  Future<UserProfile> getProfile() async {
    try {
      return _fetchProfile();
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<UserProfile> _fetchProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthFailure(message: 'No hay sesión activa');
    }
    final data = await _client
        .from(SupabaseConstants.profiles)
        .select()
        .eq('id', user.id)
        .single();
    return UserProfile.fromJson(data);
  }
}

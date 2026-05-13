import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/auth/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late AuthRepository repo;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    repo = AuthRepository(mockClient);
  });

  group('AuthRepository — getters de sesión', () {
    test('currentUser delega en GoTrueClient y devuelve null sin sesión', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(repo.currentUser, isNull);
    });

    test('currentSession delega en GoTrueClient y devuelve null sin sesión',
        () {
      when(() => mockAuth.currentSession).thenReturn(null);
      expect(repo.currentSession, isNull);
    });
  });

  group('AuthRepository.signIn', () {
    test('lanza AuthFailure cuando Supabase devuelve AuthException', () {
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException('invalid_credentials'));

      expect(
        () => repo.signIn(email: 'test@test.com', password: 'wrong'),
        throwsA(
          isA<AuthFailure>().having(
            (f) => f.message,
            'message',
            contains('invalid_credentials'),
          ),
        ),
      );
    });

    test('lanza UnexpectedFailure ante errores genéricos', () {
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('network error'));

      expect(
        () => repo.signIn(email: 'test@test.com', password: '1234'),
        throwsA(isA<UnexpectedFailure>()),
      );
    });
  });

  group('AuthRepository.signOut', () {
    test('lanza AuthFailure ante AuthException', () {
      when(() => mockAuth.signOut()).thenThrow(const AuthException('session_expired'));

      expect(
        () => repo.signOut(),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('completa sin error en caso exitoso', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await expectLater(repo.signOut(), completes);
    });
  });
}

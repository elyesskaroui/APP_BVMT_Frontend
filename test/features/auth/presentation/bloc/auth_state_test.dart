import 'package:flutter_test/flutter_test.dart';
import 'package:bvmt/features/auth/presentation/bloc/auth_state.dart';
import 'package:bvmt/features/auth/presentation/bloc/auth_event.dart';

void main() {
  group('AuthState', () {
    test('état par défaut a status initial', () {
      const state = AuthState();
      expect(state.status, AuthStatus.initial);
      expect(state.userName, isNull);
      expect(state.errorMessage, isNull);
    });

    test('copyWith remplace les champs spécifiés', () {
      const state = AuthState();
      final updated = state.copyWith(
        status: AuthStatus.authenticated,
        userName: 'Mariam',
      );
      expect(updated.status, AuthStatus.authenticated);
      expect(updated.userName, 'Mariam');
      expect(updated.errorMessage, isNull);
    });

    test('copyWith conserve les champs non spécifiés', () {
      const state = AuthState(
        status: AuthStatus.authenticated,
        userName: 'Mariam',
      );
      final updated = state.copyWith(errorMessage: 'Erreur');
      expect(updated.status, AuthStatus.authenticated);
      expect(updated.userName, 'Mariam');
      expect(updated.errorMessage, 'Erreur');
    });

    test('Equatable : états identiques sont égaux', () {
      const s1 = AuthState(status: AuthStatus.loading);
      const s2 = AuthState(status: AuthStatus.loading);
      expect(s1, equals(s2));
    });

    test('Equatable : états différents ne sont pas égaux', () {
      const s1 = AuthState(status: AuthStatus.loading);
      const s2 = AuthState(status: AuthStatus.failure);
      expect(s1, isNot(equals(s2)));
    });
  });

  group('AuthEvent', () {
    test('AuthLoginRequested props contient email et password', () {
      const event = AuthLoginRequested(
        email: 'test@test.com',
        password: '123456',
      );
      expect(event.props, ['test@test.com', '123456']);
    });

    test('AuthRegisterRequested props contient les 3 champs', () {
      const event = AuthRegisterRequested(
        fullName: 'Mariam',
        email: 'test@test.com',
        password: '123456',
      );
      expect(event.props, ['Mariam', 'test@test.com', '123456']);
    });

    test('AuthLogoutRequested a des props vides', () {
      final event = AuthLogoutRequested();
      expect(event.props, isEmpty);
    });

    test('deux AuthLoginRequested identiques sont égaux', () {
      const e1 = AuthLoginRequested(email: 'a@b.c', password: '123');
      const e2 = AuthLoginRequested(email: 'a@b.c', password: '123');
      expect(e1, equals(e2));
    });
  });

  group('AuthStatus', () {
    test('contient toutes les valeurs', () {
      expect(AuthStatus.values, [
        AuthStatus.initial,
        AuthStatus.loading,
        AuthStatus.authenticated,
        AuthStatus.unauthenticated,
        AuthStatus.failure,
      ]);
    });
  });
}

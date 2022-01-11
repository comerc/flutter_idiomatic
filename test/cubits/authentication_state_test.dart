import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_idiomatic/import.dart';

// ignore: avoid_implementing_value_types
class MockUserModel extends Mock implements UserModel {}

void main() {
  group('AuthenticationState', () {
    group('unauthenticated', () {
      test('has correct status', () {
        final state = AuthenticationState.unauthenticated();
        expect(state.status, AuthenticationStatus.unauthenticated);
        expect(state.user, UserModel.empty);
      });
    });

    group('authenticated', () {
      test('has correct status', () {
        final user = MockUserModel();
        final state = AuthenticationState.authenticated(user);
        expect(state.status, AuthenticationStatus.authenticated);
        expect(state.user, user);
      });
    });
  });
}

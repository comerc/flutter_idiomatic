import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_idiomatic/import.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

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

  group('AuthenticationCubit', () {
    final user = MockUserModel();
    late AuthenticationRepository authenticationRepository;

    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
      when(() => authenticationRepository.user).thenAnswer(
        (_) => Stream.empty(),
      );
      when(
        () => authenticationRepository.currentUser,
      ).thenReturn(UserModel.empty);
    });

    test(
        'initial state is AuthenticationState.unauthenticated when user is empty',
        () async {
      final authenticationCubit = AuthenticationCubit(authenticationRepository);
      expect(authenticationCubit.state, AuthenticationState.unauthenticated());
      await authenticationCubit.close();
    });

    blocTest<AuthenticationCubit, AuthenticationState>(
      'subscribes to user stream',
      build: () {
        when(() => authenticationRepository.user).thenAnswer(
          (_) => Stream.value(user),
        );
        return AuthenticationCubit(authenticationRepository);
      },
      expect: () => <AuthenticationState>[
        AuthenticationState.authenticated(user),
      ],
    );

    group('changeUser', () {
      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits [authenticated] when user is not empty',
        setUp: () {
          when(() => user.isNotEmpty).thenReturn(true);
          when(() => authenticationRepository.user).thenAnswer(
            (_) => Stream.value(user),
          );
        },
        build: () => AuthenticationCubit(authenticationRepository),
        // act: (bloc) => bloc.changeUser(user), // TODO: ?
        seed: () => AuthenticationState.unauthenticated(),
        expect: () => <AuthenticationState>[
          AuthenticationState.authenticated(user),
        ],
      );

      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits [unauthenticated] when user is empty',
        setUp: () {
          when(() => authenticationRepository.user).thenAnswer(
            (_) => Stream.value(UserModel.empty),
          );
        },
        build: () => AuthenticationCubit(authenticationRepository),
        // act: (bloc) => bloc.changeUser(UserModel.empty), // TODO: ?
        expect: () => <AuthenticationState>[
          AuthenticationState.unauthenticated(),
        ],
      );
    });

    group('requestLogout', () {
      blocTest<AuthenticationCubit, AuthenticationState>(
        'calls logOut on authenticationRepository '
        'when AuthenticationLogoutRequested is added',
        setUp: () {
          when(
            () => authenticationRepository.logOut(),
          ).thenAnswer((_) async {});
        },
        build: () => AuthenticationCubit(authenticationRepository),
        act: (bloc) => bloc.requestLogout(),
        verify: (_) {
          verify(
            () => authenticationRepository.logOut(),
          ).called(1);
        },
      );
    });
  });
}

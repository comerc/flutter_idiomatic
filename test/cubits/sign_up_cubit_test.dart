import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_idiomatic/import.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  const invalidEmailString = 'invalid';
  const invalidEmail = EmailInputModel.dirty(invalidEmailString);

  const validEmailString = 'test@gmail.com';
  const validEmail = EmailInputModel.dirty(validEmailString);

  const invalidPasswordString = 'invalid';
  const invalidPassword = PasswordInputModel.dirty(invalidPasswordString);

  const validPasswordString = 't0pS3cret1234';
  const validPassword = PasswordInputModel.dirty(validPasswordString);

  const invalidConfirmedPasswordString = 'invalid';
  const invalidConfirmedPassword = ConfirmedPasswordInputModel.dirty(
    password: validPasswordString,
    value: invalidConfirmedPasswordString,
  );

  const validConfirmedPasswordString = 't0pS3cret1234';
  const validConfirmedPassword = ConfirmedPasswordInputModel.dirty(
    password: validPasswordString,
    value: validConfirmedPasswordString,
  );

  group('SignUpCubit', () {
    late AuthenticationRepository authenticationRepository;

    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
      when(
        () => authenticationRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});
    });

    test('initial state is SignUpState', () async {
      final signUpCubit = SignUpCubit(authenticationRepository);
      expect(signUpCubit.state, SignUpState());
      await signUpCubit.close();
    });

    group('doEmailChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.doEmailChanged(invalidEmailString),
        expect: () => <SignUpState>[
          SignUpState(emailInput: invalidEmail, status: FormzStatus.invalid),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          passwordInput: validPassword,
          confirmedPasswordInput: validConfirmedPassword,
        ),
        act: (cubit) => cubit.doEmailChanged(validEmailString),
        expect: () => <SignUpState>[
          SignUpState(
            emailInput: validEmail,
            passwordInput: validPassword,
            confirmedPasswordInput: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );
    });

    group('doPasswordChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.doPasswordChanged(invalidPasswordString),
        expect: () => <SignUpState>[
          SignUpState(
            confirmedPasswordInput: ConfirmedPasswordInputModel.dirty(
              password: invalidPasswordString,
            ),
            passwordInput: invalidPassword,
            status: FormzStatus.invalid,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          emailInput: validEmail,
          confirmedPasswordInput: validConfirmedPassword,
        ),
        act: (cubit) => cubit.doPasswordChanged(validPasswordString),
        expect: () => <SignUpState>[
          SignUpState(
            emailInput: validEmail,
            passwordInput: validPassword,
            confirmedPasswordInput: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when confirmedPasswordChanged is called first and then '
        'passwordChanged is called',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          emailInput: validEmail,
        ),
        act: (cubit) => cubit
          ..doConfirmedPasswordChanged(validConfirmedPasswordString)
          ..doPasswordChanged(validPasswordString),
        expect: () => const <SignUpState>[
          SignUpState(
            emailInput: validEmail,
            confirmedPasswordInput: validConfirmedPassword,
            status: FormzStatus.invalid,
          ),
          SignUpState(
            emailInput: validEmail,
            passwordInput: validPassword,
            confirmedPasswordInput: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );
    });

    group('doConfirmedPasswordChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) =>
            cubit.doConfirmedPasswordChanged(invalidConfirmedPasswordString),
        expect: () => <SignUpState>[
          SignUpState(
            confirmedPasswordInput: invalidConfirmedPassword,
            status: FormzStatus.invalid,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () =>
            SignUpState(emailInput: validEmail, passwordInput: validPassword),
        act: (cubit) => cubit.doConfirmedPasswordChanged(
          validConfirmedPasswordString,
        ),
        expect: () => <SignUpState>[
          SignUpState(
            emailInput: validEmail,
            passwordInput: validPassword,
            confirmedPasswordInput: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when passwordChanged is called first and then '
        'confirmedPasswordChanged is called',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(emailInput: validEmail),
        act: (cubit) => cubit
          ..doPasswordChanged(validPasswordString)
          ..doConfirmedPasswordChanged(validConfirmedPasswordString),
        expect: () => const <SignUpState>[
          SignUpState(
            emailInput: validEmail,
            passwordInput: validPassword,
            confirmedPasswordInput: ConfirmedPasswordInputModel.dirty(
              password: validPasswordString,
            ),
            status: FormzStatus.invalid,
          ),
          SignUpState(
            emailInput: validEmail,
            passwordInput: validPassword,
            confirmedPasswordInput: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );
    });

    group('signUpFormSubmitted', () {
      blocTest<SignUpCubit, SignUpState>(
        'does nothing when status is not validated',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => <SignUpState>[],
      );

      blocTest<SignUpCubit, SignUpState>(
        'calls signUp with correct email/password/confirmedPassword',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          status: FormzStatus.valid,
          emailInput: validEmail,
          passwordInput: validPassword,
          confirmedPasswordInput: validConfirmedPassword,
        ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        verify: (_) {
          verify(
            () => authenticationRepository.signUp(
              email: validEmailString,
              password: validPasswordString,
            ),
          ).called(1);
        },
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [submissionInProgress, submissionSuccess] '
        'when signUp succeeds',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          status: FormzStatus.valid,
          emailInput: validEmail,
          passwordInput: validPassword,
          confirmedPasswordInput: validConfirmedPassword,
        ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => <SignUpState>[
          SignUpState(
            status: FormzStatus.submissionInProgress,
            emailInput: validEmail,
            passwordInput: validPassword,
            confirmedPasswordInput: validConfirmedPassword,
          ),
          SignUpState(
            status: FormzStatus.submissionSuccess,
            emailInput: validEmail,
            passwordInput: validPassword,
            confirmedPasswordInput: validConfirmedPassword,
          )
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [submissionInProgress, submissionFailure] '
        'when signUp fails',
        setUp: () {
          when(() => authenticationRepository.signUp(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenThrow(Exception('oops'));
        },
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          status: FormzStatus.valid,
          emailInput: validEmail,
          passwordInput: validPassword,
          confirmedPasswordInput: validConfirmedPassword,
        ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => <SignUpState>[
          SignUpState(
            status: FormzStatus.submissionInProgress,
            emailInput: validEmail,
            passwordInput: validPassword,
            confirmedPasswordInput: validConfirmedPassword,
          ),
          SignUpState(
            status: FormzStatus.submissionFailure,
            emailInput: validEmail,
            passwordInput: validPassword,
            confirmedPasswordInput: validConfirmedPassword,
          )
        ],
      );
    });
  });
}

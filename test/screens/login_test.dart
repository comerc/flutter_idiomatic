import 'package:flutter/material.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_firebase_login/import.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockLoginCubit extends MockBloc<LoginState> implements LoginCubit {}

// ignore: avoid_implementing_value_types
class MockEmailInputModel extends Mock implements EmailInputModel {}

// ignore: avoid_implementing_value_types
class MockPasswordInputModel extends Mock implements PasswordInputModel {}

void main() {
  group('LoginScreen', () {
    test('has a route', () {
      expect(LoginScreen().getRoute(), isA<Route>());
    });

    testWidgets('renders a LoginForm', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider<AuthenticationRepository>.value(
          value: MockAuthenticationRepository(),
          child: MaterialApp(home: LoginScreen()),
        ),
      );
      expect(find.byType(LoginForm), findsOneWidget);
    });
  });

  const testEmail = 'test@gmail.com';
  const testPassword = 'testP@ssw0rd1';

  group('LoginForm', () {
    LoginCubit loginCubit;

    setUp(() {
      loginCubit = MockLoginCubit();
      when(loginCubit.state).thenReturn(LoginState());
    });

    group('calls', () {
      testWidgets('doEmailChanged when email changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: LoginForm(),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(Key('_EmailInput')), testEmail);
        verify(loginCubit.doEmailChanged(testEmail)).called(1);
      });

      testWidgets('doPasswordChanged when password changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: LoginForm(),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(Key('_PasswordInput')), testPassword);
        verify(loginCubit.doPasswordChanged(testPassword)).called(1);
      });

      testWidgets('logInWithCredentials when login button is pressed',
          (tester) async {
        when(loginCubit.state).thenReturn(
          LoginState(status: FormzStatus.valid),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: LoginForm(),
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(Key('_LoginButton')));
        verify(loginCubit.logInWithCredentials()).called(1);
      });

      testWidgets('logInWithGoogle when sign in with google button is pressed',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: LoginForm(),
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(Key('_GoogleLoginButton')));
        verify(loginCubit.logInWithGoogle()).called(1);
      });
    });

    group('renders', () {
      testWidgets('AuthenticationFailure SnackBar when submission fails',
          (tester) async {
        whenListen(
          loginCubit,
          Stream.fromIterable(<LoginState>[
            LoginState(status: FormzStatus.submissionInProgress),
            LoginState(status: FormzStatus.submissionFailure),
          ]),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: LoginForm(),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Authentication Failure'), findsOneWidget);
      });

      testWidgets('invalid email error text when email is invalid',
          (tester) async {
        final emailInput = MockEmailInputModel();
        when(emailInput.invalid).thenReturn(true);
        when(loginCubit.state).thenReturn(LoginState(emailInput: emailInput));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: LoginForm(),
              ),
            ),
          ),
        );
        expect(find.text('invalid email'), findsOneWidget);
      });

      testWidgets('invalid password error text when password is invalid',
          (tester) async {
        final passwordInput = MockPasswordInputModel();
        when(passwordInput.invalid).thenReturn(true);
        when(loginCubit.state)
            .thenReturn(LoginState(passwordInput: passwordInput));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: LoginForm(),
              ),
            ),
          ),
        );
        expect(find.text('invalid password'), findsOneWidget);
      });

      testWidgets('disabled login button when status is not validated',
          (tester) async {
        when(loginCubit.state).thenReturn(
          LoginState(status: FormzStatus.invalid),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: LoginForm(),
              ),
            ),
          ),
        );
        final loginButton = tester.widget<RaisedButton>(
          find.byKey(Key('_LoginButton')),
        );
        expect(loginButton.enabled, isFalse);
      });

      testWidgets('enabled login button when status is validated',
          (tester) async {
        when(loginCubit.state).thenReturn(
          LoginState(status: FormzStatus.valid),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: LoginForm(),
              ),
            ),
          ),
        );
        final loginButton = tester.widget<RaisedButton>(
          find.byKey(Key('_LoginButton')),
        );
        expect(loginButton.enabled, isTrue);
      });

      testWidgets('Sign in with Google Button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: LoginForm(),
              ),
            ),
          ),
        );
        expect(find.byKey(Key('_GoogleLoginButton')), findsOneWidget);
      });
    });

    group('navigates', () {
      testWidgets('to SignUpScreen when Create Account is pressed',
          (tester) async {
        await tester.pumpWidget(
          RepositoryProvider<AuthenticationRepository>(
            create: (_) => MockAuthenticationRepository(),
            child: MaterialApp(
              navigatorKey: navigatorKey,
              home: Scaffold(
                body: BlocProvider.value(
                  value: loginCubit,
                  child: LoginForm(),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(Key('_SignUpButton')));
        await tester.pumpAndSettle();
        expect(find.byType(SignUpScreen), findsOneWidget);
      });
    });
  });
}

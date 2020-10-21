// // ignore_for_file: prefer_const_constructors
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_firebase_login/import.dart';

// ignore: must_be_immutable
class MockUser extends Mock implements UserModel {
  @override
  String get id => 'id';

  @override
  String get name => 'Joe';

  @override
  String get email => 'joe@gmail.com';
}

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockAuthenticationCubit extends MockBloc<AuthenticationState>
    implements AuthenticationCubit {}

void main() {
  group('App', () {
    AuthenticationRepository authenticationRepository;

    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
      when(authenticationRepository.user).thenAnswer(
        (_) => const Stream.empty(),
      );
    });

    test('throws AssertionError when authenticationRepository is null', () {
      expect(() => App(authenticationRepository: null), throwsAssertionError);
    });

    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(
        App(authenticationRepository: authenticationRepository),
      );
      expect(find.byType(AppView), findsOneWidget);
    });
  });

  group('AppView', () {
    AuthenticationCubit authenticationCubit;
    AuthenticationRepository authenticationRepository;

    setUp(() {
      authenticationCubit = MockAuthenticationCubit();
      authenticationRepository = MockAuthenticationRepository();
    });

    testWidgets('renders SplashScreen by default', (tester) async {
      await tester.pumpWidget(
        BlocProvider.value(value: authenticationCubit, child: AppView()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('navigates to LoginScreen when status is unauthenticated',
        (tester) async {
      whenListen(
        authenticationCubit,
        Stream.value(const AuthenticationState.unauthenticated()),
      );
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: authenticationRepository,
          child: BlocProvider.value(
            value: authenticationCubit,
            child: AppView(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('navigates to HomeScreen when status is authenticated',
        (tester) async {
      whenListen(
        authenticationCubit,
        Stream.value(AuthenticationState.authenticated(MockUser())),
      );
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: authenticationRepository,
          child: BlocProvider.value(
            value: authenticationCubit,
            child: AppView(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}

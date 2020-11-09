import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_firebase_login/import.dart';

// ignore: must_be_immutable, avoid_implementing_value_types
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

class MockGitHubRepository extends Mock implements GitHubRepository {}

class MockDatabaseRepository extends Mock implements DatabaseRepository {}

void main() {
  group('App', () {
    AuthenticationRepository authenticationRepository;
    GitHubRepository gitHubRepository;
    DatabaseRepository databaseRepository;

    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
      gitHubRepository = MockGitHubRepository();
      databaseRepository = MockDatabaseRepository();
      when(authenticationRepository.user).thenAnswer(
        (_) => Stream.empty(),
      );
    });

    test('throws AssertionError when authenticationRepository is null', () {
      expect(
        () => App(
          authenticationRepository: null,
          gitHubRepository: null,
          databaseRepository: null,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(
        App(
          authenticationRepository: authenticationRepository,
          gitHubRepository: gitHubRepository,
          databaseRepository: databaseRepository,
        ),
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
        Stream.value(AuthenticationState.unauthenticated()),
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

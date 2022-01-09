import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_idiomatic/import.dart';

class MockUser extends Mock implements UserModel {}

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockAuthenticationCubit extends MockCubit<AuthenticationState>
    implements AuthenticationCubit {}

class MockGitHubRepository extends Mock implements GitHubRepository {}

class MockDatabaseRepository extends Mock implements DatabaseRepository {}

void main() {
  group('App', () {
    late AuthenticationRepository authenticationRepository;
    late UserModel user;
    late GitHubRepository gitHubRepository;
    late DatabaseRepository databaseRepository;
    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
      user = MockUser();
      gitHubRepository = MockGitHubRepository();
      databaseRepository = MockDatabaseRepository();
      when(() => authenticationRepository.user).thenAnswer(
        (_) => Stream.empty(),
      );
      when(() => authenticationRepository.currentUser).thenReturn(user);
      when(() => user.isNotEmpty).thenReturn(true);
      when(() => user.isEmpty).thenReturn(false);
      when(() => user.email).thenReturn('test@gmail.com');
    });
    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(
        App(
          authenticationRepository: authenticationRepository,
          gitHubRepository: gitHubRepository,
          databaseRepository: databaseRepository,
        ),
      );
      await tester.pump();
      expect(find.byType(AppView), findsOneWidget);
    });
  });
  group('AppView', () {
    late AuthenticationRepository authenticationRepository;
    late AuthenticationCubit authenticationCubit;
    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
      authenticationCubit = MockAuthenticationCubit();
    });
    testWidgets('renders SplashScreen by default', (tester) async {
      await tester.pumpWidget(
        BlocProvider.value(value: authenticationCubit, child: AppView()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsOneWidget);
    });
    testWidgets('navigates to LoginScreen when unauthenticated',
        (tester) async {
      when(() => authenticationCubit.state)
          .thenReturn(AuthenticationState.unauthenticated());
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
    testWidgets('navigates to HomeScreen when authenticated', (tester) async {
      final user = MockUser();
      when(() => user.email).thenReturn('test@gmail.com');
      when(() => authenticationCubit.state)
          .thenReturn(AuthenticationState.authenticated(user));

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

import 'package:flutter/material.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_idiomatic/import.dart';

class MockAuthenticationCubit extends MockCubit<AuthenticationState>
    implements AuthenticationCubit {}

// ignore: avoid_implementing_value_types
class MockUserModel extends Mock implements UserModel {}

void main() {
  group('HomeScreen', () {
    late AuthenticationCubit authenticationCubit;
    late UserModel user;

    setUp(() {
      authenticationCubit = MockAuthenticationCubit();
      user = MockUserModel();
      when(() => user.email).thenReturn('test@gmail.com');
      when(() => authenticationCubit.state)
          .thenReturn(AuthenticationState.authenticated(user));
    });

    test('has a route', () {
      expect(HomeScreen().getRoute(), isA<Route>());
    });

    group('calls', () {
      testWidgets('AuthenticationLogoutRequested when logout is pressed',
          (tester) async {
        await tester.pumpWidget(
          BlocProvider.value(
            value: authenticationCubit,
            child: MaterialApp(
              home: HomeScreen(),
            ),
          ),
        );
        await tester.tap(find.byKey(Key('_LogoutButton')));
        verify(() => authenticationCubit.requestLogout()).called(1);
      });
    });

    group('renders', () {
      testWidgets('avatar widget', (tester) async {
        await tester.pumpWidget(
          BlocProvider.value(
            value: authenticationCubit,
            child: MaterialApp(
              home: HomeScreen(),
            ),
          ),
        );
        expect(find.byType(Avatar), findsOneWidget);
      });

      testWidgets('email address', (tester) async {
        await tester.pumpWidget(
          BlocProvider.value(
            value: authenticationCubit,
            child: MaterialApp(
              home: HomeScreen(),
            ),
          ),
        );
        expect(find.text('test@gmail.com'), findsOneWidget);
      });

      testWidgets('name', (tester) async {
        when(() => user.name).thenReturn('Joe');
        await tester.pumpWidget(
          BlocProvider.value(
            value: authenticationCubit,
            child: MaterialApp(
              home: HomeScreen(),
            ),
          ),
        );
        expect(find.text('Joe'), findsOneWidget);
      });
    });
  });
}

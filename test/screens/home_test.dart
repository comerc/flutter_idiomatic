import 'package:flutter/material.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_firebase_login/import.dart';

class MockAuthenticationBloc extends MockBloc<AuthenticationState>
    implements AuthenticationCubit {}

// ignore: must_be_immutable, avoid_implementing_value_types
class MockUserModel extends Mock implements UserModel {
  @override
  String get email => 'test@gmail.com';
}

void main() {
  group('HomeScreen', () {
    AuthenticationCubit authenticationBloc;
    UserModel user;

    setUp(() {
      authenticationBloc = MockAuthenticationBloc();
      user = MockUserModel();
      when(authenticationBloc.state).thenReturn(
        AuthenticationState.authenticated(user),
      );
    });

    test('has a route', () {
      expect(HomeScreen().getRoute(), isA<Route>());
    });

    group('calls', () {
      testWidgets('AuthenticationLogoutRequested when logout is pressed',
          (tester) async {
        await tester.pumpWidget(
          BlocProvider.value(
            value: authenticationBloc,
            child: MaterialApp(
              home: HomeScreen(),
            ),
          ),
        );
        await tester.tap(find.byKey(Key('_LogoutBotton')));
        verify(authenticationBloc.requestLogout()).called(1);
      });
    });

    group('renders', () {
      testWidgets('avatar widget', (tester) async {
        await tester.pumpWidget(
          BlocProvider.value(
            value: authenticationBloc,
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
            value: authenticationBloc,
            child: MaterialApp(
              home: HomeScreen(),
            ),
          ),
        );
        expect(find.text('test@gmail.com'), findsOneWidget);
      });

      testWidgets('name', (tester) async {
        when(user.name).thenReturn('Joe');
        await tester.pumpWidget(
          BlocProvider.value(
            value: authenticationBloc,
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

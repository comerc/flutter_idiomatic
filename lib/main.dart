import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bot_toast/bot_toast.dart';
// import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_idiomatic/import.dart';

void main() {
  // timeDilation = 10.0; // Will slow down animations by a factor of two
  // debugPaintSizeEnabled = true;
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   if (kDebugMode) {
  //     // In development mode, simply print to console.
  //     FlutterError.dumpErrorToConsole(details);
  //   } else {
  //     // In production mode, report to the application zone to report to
  //     // Sentry.
  //     Zone.current.handleUncaughtError(details.exception, details.stack);
  //   }
  // };
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    EquatableConfig.stringify = kDebugMode;
    // Bloc.observer = SimpleBlocObserver();
    HydratedBloc.storage = await HydratedStorage.build();
    runApp(
      App(
        authenticationRepository: AuthenticationRepository(),
        gitHubRepository: GitHubRepository(),
        databaseRepository: DatabaseRepository(),
      ),
    );
  }, (error, stackTrace) {
    // Whenever an error occurs, call the `_reportError` function. This sends
    // Dart errors to the dev console or Sentry depending on the environment.
    // _reportError(error, stackTrace);
  });
}

class App extends StatelessWidget {
  App({
    Key key,
    @required this.authenticationRepository,
    @required this.gitHubRepository,
    @required this.databaseRepository,
  })  : assert(authenticationRepository != null),
        assert(gitHubRepository != null),
        assert(databaseRepository != null),
        super(key: key);

  final AuthenticationRepository authenticationRepository;
  final GitHubRepository gitHubRepository;
  final DatabaseRepository databaseRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: authenticationRepository,
        ),
        RepositoryProvider.value(
          value: gitHubRepository,
        ),
        RepositoryProvider.value(
          value: databaseRepository,
        ),
      ],
      child: BlocProvider(
        create: (BuildContext context) =>
            AuthenticationCubit(authenticationRepository),
        child: AppView(),
      ),
    );
  }
}

final navigatorKey = GlobalKey<NavigatorState>(); // видимость нужна для тестов

NavigatorState get navigator => navigatorKey.currentState;

class AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      navigatorKey: navigatorKey,
      navigatorObservers: [
        BotToastNavigatorObserver(),
      ],
      // home: TodosScreen(),
      builder: (BuildContext context, Widget child) {
        var result = child;
        result = BlocListener<AuthenticationCubit, AuthenticationState>(
          listener: (BuildContext context, AuthenticationState state) {
            final cases = {
              AuthenticationStatus.authenticated: () {
                navigator.pushAndRemoveUntil<void>(
                  HomeScreen().getRoute(),
                  (Route route) => false,
                );
              },
              AuthenticationStatus.unauthenticated: () {
                navigator.pushAndRemoveUntil<void>(
                  LoginScreen().getRoute(),
                  (Route route) => false,
                );
              },
              AuthenticationStatus.unknown: () {},
            };
            assert(cases.length == AuthenticationStatus.values.length);
            cases[state.status]();
          },
          child: result,
        );
        result = BotToastInit()(context, result);
        return result;
      },
      onGenerateRoute: (_) => SplashScreen().getRoute(),
    );
  }
}

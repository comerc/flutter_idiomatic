import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/import.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_firebase_login/common/_mutations.dart' as mutations;
import 'package:flutter_firebase_login/common/_queries.dart' as queries;
import 'package:flutter_firebase_login/common/helpers.dart'
    show withGenericHandling;
// ignore: uri_does_not_exist
import 'package:flutter_firebase_login/local.dart';

void main() {
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
    runApp(App());
  }, (error, stackTrace) {
    // Whenever an error occurs, call the `_reportError` function. This sends
    // Dart errors to the dev console or Sentry depending on the environment.
    // _reportError(error, stackTrace);
  });
}

final navigatorKey = GlobalKey<NavigatorState>();

NavigatorState get navigator => navigatorKey.currentState;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      navigatorKey: navigatorKey,
      home: GraphQLWidgetScreen(),
    );
  }
}

// ****

const bool kEnableWebsockets = false;

class GraphQLWidgetScreen extends StatelessWidget {
  const GraphQLWidgetScreen() : super();

  @override
  Widget build(BuildContext context) {
    final httpLink = HttpLink(
      uri: 'https://api.github.com/graphql',
    );

    final authLink = AuthLink(
      // ignore: undefined_identifier
      getToken: () async => 'Bearer $kPersonalAccessToken',
    );

    var link = authLink.concat(httpLink);

    if (kEnableWebsockets) {
      final websocketLink = WebSocketLink(
        url: 'ws://localhost:8080/ws/graphql',
        config: SocketClientConfig(
            autoReconnect: true, inactivityTimeout: Duration(seconds: 15)),
      );

      link = link.concat(websocketLink);
    }

    final client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        cache: OptimisticCache(
          dataIdFromObject: typenameDataIdFromObject,
        ),
        link: link,
      ),
    );

    return GraphQLProvider(
      client: client,
      child: const CacheProvider(
        child: MyHomePage(title: 'GraphQL Widget'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key key,
    this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int nRepositories = 50;

  void changeQuery(String number) {
    setState(() {
      nRepositories = int.parse(number) ?? 50;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                labelText: 'Number of repositories (default 50)',
              ),
              keyboardType: TextInputType.number,
              onSubmitted: changeQuery,
            ),
            Query(
              options: QueryOptions(
                documentNode: gql(queries.readRepositories),
                variables: <String, dynamic>{
                  'nRepositories': nRepositories,
                },
                //pollInterval: 10,
              ),
              builder: withGenericHandling(
                (QueryResult result, {refetch, fetchMore}) {
                  if (result.data == null && !result.hasException) {
                    return const Text(
                        'Both data and errors are null, this is a known bug after refactoring, you might forget to set Github token');
                  }

                  // result.data can be either a [List<dynamic>] or a [Map<String, dynamic>]
                  final repositories = (result.data['viewer']['repositories']
                          ['nodes'] as List<dynamic>)
                      .cast<LazyCacheMap>();

                  return Expanded(
                    child: ListView.builder(
                      itemCount: repositories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return StarrableRepository(
                            repository: repositories[index]);
                      },
                    ),
                  );
                },
              ),
            ),
            kEnableWebsockets
                ? Subscription<Map<String, dynamic>>(
                    'test', queries.testSubscription, builder: ({
                    bool loading,
                    Map<String, dynamic> payload,
                    dynamic error,
                  }) {
                    return loading
                        ? const Text('Loading...')
                        : Text(payload.toString());
                  })
                : const Text(''),
          ],
        ),
      ),
    );
  }
}

class StarrableRepository extends StatelessWidget {
  const StarrableRepository({
    Key key,
    @required this.repository,
  }) : super(key: key);

  final Map<String, Object> repository;

  Map<String, Object> extractRepositoryData(Object data) {
    final action =
        (data as Map<String, Object>)['action'] as Map<String, Object>;
    if (action == null) {
      return null;
    }
    return action['starrable'] as Map<String, Object>;
  }

  bool get starred => repository['viewerHasStarred'] as bool;
  bool get optimistic => (repository as LazyCacheMap).isOptimistic;

  Map<String, dynamic> get expectedResult => <String, dynamic>{
        'action': <String, dynamic>{
          'starrable': <String, dynamic>{'viewerHasStarred': !starred}
        }
      };

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        documentNode: gql(starred ? mutations.removeStar : mutations.addStar),
        update: (Cache cache, QueryResult result) {
          if (result.hasException) {
            print(result.exception);
          } else {
            final updated = Map<String, Object>.from(repository)
              ..addAll(extractRepositoryData(result.data));
            cache.write(typenameDataIdFromObject(updated), updated);
          }
        },
        onError: (OperationException error) {
          showDialog<AlertDialog>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(error.toString()),
                actions: <Widget>[
                  SimpleDialogOption(
                    child: const Text('DISMISS'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        },
        onCompleted: (dynamic resultData) {
          showDialog<AlertDialog>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  extractRepositoryData(resultData)['viewerHasStarred'] as bool
                      ? 'Thanks for your star!'
                      : 'Sorry you changed your mind!',
                ),
                actions: <Widget>[
                  SimpleDialogOption(
                    child: const Text('DISMISS'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        },
      ),
      builder: (RunMutation toggleStar, QueryResult result) {
        return ListTile(
          leading: starred
              ? const Icon(
                  Icons.star,
                  color: Colors.amber,
                )
              : const Icon(Icons.star_border),
          trailing: result.loading || optimistic
              ? const CircularProgressIndicator()
              : null,
          title: Text(repository['name'] as String),
          onTap: () {
            toggleStar(
              <String, dynamic>{
                'starrableId': repository['id'],
              },
              optimisticResult: expectedResult,
            );
          },
        );
      },
    );
  }
}

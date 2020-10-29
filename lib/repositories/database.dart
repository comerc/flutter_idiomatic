import 'package:graphql/client.dart';
import 'package:flutter_firebase_login/import.dart';

// ignore: uri_does_not_exist
import '../local.dart';

const _kEnableWebsockets = true;

class DatabaseRepository {
  DatabaseRepository({GraphQLClient client}) : _client = client ?? _getClient();

  final GraphQLClient _client;

  Future<List<TodoModel>> readMyTodos({DateTime createdAt, int limit}) async {
    final options = QueryOptions(
      documentNode: _API.readMyTodos,
      variables: {
        'user_id': kDatabaseUserId,
        'created_at': (createdAt ?? DateTime.now().toUtc()).toIso8601String(),
        'limit': limit,
      },
      fetchPolicy: FetchPolicy.noCache,
      errorPolicy: ErrorPolicy.all,
    );
    final queryResult =
        await _client.query(options).timeout(kGraphQLQueryTimeoutDuration);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    final dataItems =
        (queryResult.data['todos'] as List).cast<Map<String, dynamic>>();
    final items = <TodoModel>[];
    for (final dataItem in dataItems) {
      items.add(TodoModel.fromJson(dataItem));
    }
    return items;
  }

  Stream<int> get fetchNewNotification {
    final operation = Operation(
      documentNode: _API.fetchNewNotification,
      // variables: null,
      // extensions: null,
      // operationName: 'FetchNewNotification',
    );
    return _client.subscribe(operation).map((FetchResult fetchResult) {
      return fetchResult.data['todos'][0]['id'] as int;
    });
  }
}

GraphQLClient _getClient() {
  final httpLink = HttpLink(
    uri: 'https://hasura.io/learn/graphql',
  );
  final authLink = AuthLink(
    getToken: () async => 'Bearer $kDatabaseToken',
  );
  var link = authLink.concat(httpLink);
  if (_kEnableWebsockets) {
    final websocketLink = WebSocketLink(
      url: 'wss://hasura.io/learn/graphql',
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: const Duration(seconds: 15),
        initPayload: () async => {
          'headers': {'Authorization': 'Bearer $kDatabaseToken'}
        },
      ),
    );
    link = link.concat(websocketLink);
  }
  return GraphQLClient(
    cache: InMemoryCache(),
    // cache: NormalizedInMemoryCache(
    //   dataIdFromObject: typenameDataIdFromObject,
    // ),
    // cache: OptimisticCache(
    //   dataIdFromObject: typenameDataIdFromObject,
    // ),
    link: link,
  );
}

class _API {
  static final fetchNewNotification = gql(r'''
    subscription FetchNewNotification {
      todos(limit: 1, order_by: {created_at: desc}) {
        id
      }
    }
  ''');
  //where: {is_public: {_eq: true}},

  static final readMyTodos = gql(r'''
    query ReadMyTodos($user_id: String!, $created_at: timestamptz!, $limit: Int!) {
      todos(
        where: {
          user_id: {_eq: $user_id},
          created_at: {_lte: $created_at}
        },
        order_by: { created_at: desc },
        limit: $limit,
      ) {
        ...TodosFields
      }
    }
  ''')..definitions.addAll(fragments.definitions);

  static final fragments = gql(r'''
    fragment TodosFields on todos {
      # __typename
      id
      title
      is_completed
      created_at
    }
  ''');

  // static final addStar = gql(r'''
  //   mutation AddStar($starrableId: ID!) {
  //     action: addStar(input: {starrableId: $starrableId}) {
  //       starrable {
  //         viewerHasStarred
  //       }
  //     }
  //   }
  // ''');

  // static final removeStar = gql(r'''
  //   mutation RemoveStar($starrableId: ID!) {
  //     action: removeStar(input: {starrableId: $starrableId}) {
  //       starrable {
  //         viewerHasStarred
  //       }
  //     }
  //   }
  // ''');
}

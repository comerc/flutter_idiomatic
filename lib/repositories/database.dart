import 'package:graphql/client.dart';
import 'package:flutter_idiomatic/import.dart';

const _kEnableWebsockets = true;

class DatabaseRepository {
  DatabaseRepository({GraphQLClient client}) : _client = client ?? _getClient();

  final GraphQLClient _client;

  Future<List<TodoModel>> readTodos({DateTime createdAt, int limit}) async {
    final options = QueryOptions(
      documentNode: _API.readTodos,
      variables: {
        'user_id': kDatabaseUserId,
        'created_at': (createdAt ?? DateTime.now().toUtc()).toIso8601String(),
        'limit': limit,
      },
      fetchPolicy: FetchPolicy.noCache,
      errorPolicy: ErrorPolicy.all,
    );
    final queryResult =
        await _client.query(options).timeout(kGraphQLTimeoutDuration);
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

  Stream<int> get fetchNewTodoNotification {
    final operation = Operation(
      documentNode: _API.fetchNewTodoNotification,
      variables: {'user_id': kDatabaseUserId},
      // extensions: null,
      // operationName: 'FetchNewTodoNotification',
    );
    return _client.subscribe(operation).map((FetchResult fetchResult) {
      return fetchResult.data['todos'][0]['id'] as int;
    });
  }

  Future<int> deleteTodo(int id) async {
    final options = MutationOptions(
      documentNode: _API.deleteTodo,
      variables: {'id': id},
      fetchPolicy: FetchPolicy.noCache,
      errorPolicy: ErrorPolicy.all,
    );
    final mutationResult =
        await _client.mutate(options).timeout(kGraphQLTimeoutDuration);
    if (mutationResult.hasException) {
      throw mutationResult.exception;
    }
    return mutationResult.data['delete_todos_by_pk']['id'] as int;
  }

  Future<TodoModel> createTodo(TodosData data) async {
    final options = MutationOptions(
      documentNode: _API.createTodo,
      variables: data.toJson(),
      fetchPolicy: FetchPolicy.noCache,
      errorPolicy: ErrorPolicy.all,
    );
    final mutationResult =
        await _client.mutate(options).timeout(kGraphQLTimeoutDuration);
    if (mutationResult.hasException) {
      throw mutationResult.exception;
    }
    final dataItem =
        mutationResult.data['insert_todos_one'] as Map<String, dynamic>;
    return TodoModel.fromJson(dataItem);
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
        inactivityTimeout: const Duration(seconds: 15),
        initPayload: () async {
          out('initPayload');
          return {
            'headers': {'Authorization': 'Bearer $kDatabaseToken'},
          };
        },
      ),
    );
    link = link.concat(websocketLink);
  }
  // TODO: применение ValueNotifier и GraphQLProvider - для чего? изучить исходники
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

mixin _API {
  static final createTodo = gql(r'''
    mutation CreateTodo($title: String) {
      insert_todos_one(object: {title: $title}) {
        ...TodosFields
      }
    }
  ''')..definitions.addAll(fragments.definitions);

  static final deleteTodo = gql(r'''
    mutation DeleteTodo($id: Int!) {
      delete_todos_by_pk(id: $id) {
        id
      }
    }
  ''');

  static final fetchNewTodoNotification = gql(r'''
    subscription FetchNewTodoNotification($user_id: String!) {
      todos(
        where: {
          user_id: {_eq: $user_id},
          # is_public: {_eq: true},
        }, 
        order_by: {created_at: desc},
        limit: 1, 
      ) {
        id
      }
    }
  ''');

  static final readTodos = gql(r'''
    query ReadTodos($user_id: String!, $created_at: timestamptz!, $limit: Int!) {
      todos(
        where: {
          user_id: {_eq: $user_id},
          created_at: {_lte: $created_at},
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
      created_at
    }
  ''');
}

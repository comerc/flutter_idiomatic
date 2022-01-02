import 'package:graphql/client.dart';
import 'package:flutter_idiomatic/import.dart';

const _kEnableWebsockets = true;

class DatabaseRepository {
  DatabaseRepository({
    GraphQLService? service,
  }) : _service = service ??
            GraphQLService(
              client: _createClient(),
              queryTimeout: kGraphQLQueryTimeout,
              mutationTimeout: kGraphQLMutationTimeout,
            );

  final GraphQLService _service;

  Future<List<TodoModel>> readTodos(
      {DateTime? createdAt, required int limit}) async {
    return _service.query(
      document: DatabaseAPI.readTodos,
      variables: {
        'user_id': kDatabaseUserId,
        'created_at': (createdAt ?? DateTime.now().toUtc()).toIso8601String(),
        'limit': limit,
      },
      root: 'todos',
      convert: TodoModel.fromJson,
    );
  }

  Stream<int?> get fetchNewTodoNotification {
    return _service.subscribe(
      document: DatabaseAPI.fetchNewTodoNotification,
      variables: {'user_id': kDatabaseUserId},
      // ignore: avoid_dynamic_calls
      toRoot: (dynamic rawJson) => rawJson['todos'][0],
      convert: (Map<String, dynamic> json) => json['id'] as int,
    );
  }

  Future<int?> deleteTodo(int id) async {
    return _service.mutate(
      document: DatabaseAPI.deleteTodo,
      variables: {'id': id},
      root: 'delete_todos_by_pk',
      convert: (Map<String, dynamic> json) => json['id'] as int,
    );
  }

  Future<TodoModel?> createTodo(TodosData data) async {
    return _service.mutate(
      document: DatabaseAPI.createTodo,
      variables: data.toJson(),
      root: 'insert_todos_one',
      convert: TodoModel.fromJson,
    );
  }
}

GraphQLClient _createClient() {
  final httpLink = HttpLink(
    'https://hasura.io/learn/graphql',
  );
  final authLink = AuthLink(
    getToken: () async => 'Bearer $kDatabaseToken',
  );
  var link = authLink.concat(httpLink);
  if (_kEnableWebsockets) {
    final websocketLink = WebSocketLink(
      'wss://hasura.io/learn/graphql',
      config: SocketClientConfig(
        inactivityTimeout: const Duration(seconds: 15),
        initialPayload: () async {
          out('**** initPayload');
          return {
            'headers': {'Authorization': 'Bearer $kDatabaseToken'},
          };
        },
      ),
    );
    link = link.concat(websocketLink);
  }
  return GraphQLClient(
    cache: GraphQLCache(),
    // cache: NormalizedInMemoryCache(
    //   dataIdFromObject: typenameDataIdFromObject,
    // ),
    // cache: OptimisticCache(
    //   dataIdFromObject: typenameDataIdFromObject,
    // ),
    link: link,
  );
}

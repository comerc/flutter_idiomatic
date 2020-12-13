import 'package:graphql/client.dart';
import 'package:flutter_idiomatic/import.dart';

const _kEnableWebsockets = true;

class DatabaseRepository {
  DatabaseRepository({
    GraphQLService service,
  }) : _service = service ??
            GraphQLService(
              client: _createClient(),
              timeout: kGraphQLTimeoutDuration,
            );

  final GraphQLService _service;

  Future<List<TodoModel>> readTodos({DateTime createdAt, int limit}) async {
    return _service.query<TodoModel>(
      documentNode: _API.readTodos,
      variables: {
        'user_id': kDatabaseUserId,
        'created_at': (createdAt ?? DateTime.now().toUtc()).toIso8601String(),
        'limit': limit,
      },
      root: 'todos',
      convert: TodoModel.fromJson,
    );
  }

  Stream<int> get fetchNewTodoNotification {
    return _service.subscribe<int>(
      documentNode: _API.fetchNewTodoNotification,
      variables: {'user_id': kDatabaseUserId},
      toRoot: (dynamic rawJson) => rawJson['todos'][0],
      convert: (Map<String, dynamic> json) => json['id'] as int,
    );
  }

  Future<int> deleteTodo(int id) async {
    return _service.mutate<int>(
      documentNode: _API.deleteTodo,
      variables: {'id': id},
      root: 'delete_todos_by_pk',
      convert: (Map<String, dynamic> json) => json['id'] as int,
    );
  }

  Future<TodoModel> createTodo(TodosData data) async {
    return _service.mutate<TodoModel>(
      documentNode: _API.createTodo,
      variables: data.toJson(),
      root: 'insert_todos_one',
      convert: TodoModel.fromJson,
    );
  }
}

GraphQLClient _createClient() {
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

import 'package:graphql/client.dart';
import 'package:flutter_firebase_login/import.dart';

// ignore: uri_does_not_exist
import '../local.dart';

const _kEnableWebsockets = false;
// const _kRepositoriesLimit = 8;

class DatabaseRepository {
  DatabaseRepository({GraphQLClient client}) : _client = client ?? _getClient();

  final GraphQLClient _client;

  Future<List<TodoModel>> readMyTodos({DateTime createdAt, int limit}) async {
    final queryResult = await _client
        .query(QueryOptions(
          documentNode: _API.readMyTodos,
          variables: {
            'user_id': kDatabaseUserId,
            'created_at':
                (createdAt ?? DateTime.now().toUtc()).toIso8601String(),
            'limit': limit,
          },
          fetchPolicy: FetchPolicy.noCache,
          errorPolicy: ErrorPolicy.all,
        ))
        .timeout(kGraphQLQueryTimeoutDuration);
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
        // initPayload: () async => {
        //   'headers': {'Authorization': 'Bearer ' + token}
        // },
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

  // static final readRepositories = gql(r'''
  //   query ReadRepositories($nRepositories: Int!) {
  //     viewer {
  //       repositories(last: $nRepositories) {
  //         nodes {
  //           ...RepositoryFields
  //         }
  //       }
  //     }
  //   }
  // ''')..definitions.addAll(fragments.definitions);

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

  // static final searchRepositories = gql(r'''
  //   query SearchRepositories($nRepositories: Int!, $query: String!, $cursor: String) {
  //     search(last: $nRepositories, query: $query, type: REPOSITORY, after: $cursor) {
  //       nodes {
  //         # __typename
  //         ... on Repository {
  //           name
  //           shortDescriptionHTML
  //           viewerHasStarred
  //           stargazers {
  //             totalCount
  //           }
  //           forks {
  //             totalCount
  //           }
  //           updatedAt
  //         }
  //       }
  //       pageInfo {
  //         endCursor
  //         hasNextPage
  //       }
  //     }
  //   }
  // '''); // ..definitions.addAll(fragments.definitions);
}

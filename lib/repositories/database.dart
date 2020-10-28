import 'package:graphql/client.dart';
import 'package:flutter_firebase_login/import.dart';

// ignore: uri_does_not_exist
import '../local.dart';

const _kEnableWebsockets = false;
// const _kRepositoriesLimit = 8;

class DatabaseRepository {
  DatabaseRepository({GraphQLClient client}) : _client = client ?? _getClient();

  final GraphQLClient _client;

  Future<List<TodoModel>> readMyTodos() async {
    final queryResult = await _client
        .query(QueryOptions(
          documentNode: _API.readMyTodos,
          // variables: null,
          fetchPolicy: FetchPolicy.noCache,
        ))
        .timeout(kGraphQLQueryTimeoutDuration);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    final dataItems =
        (queryResult.data['todos'] as List).cast<Map<String, dynamic>>();
    final result = <TodoModel>[];
    for (final dataItem in dataItems) {
      result.add(TodoModel.fromJson(dataItem));
    }
    // print(dataItems.length);
    return result;
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
    query ReadMyTodos {
      todos(order_by: { created_at: desc }) {
        ...TodosFields
      }
    }
  ''')..definitions.addAll(fragments.definitions);
  // where: { is_public: { _eq: false} },

  static final fragments = gql(r'''
    fragment TodosFields on todos {
      # __typename
      id
      title
      is_completed
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

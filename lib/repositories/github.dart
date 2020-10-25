import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_firebase_login/import.dart';
// // ignore: uri_does_not_exist
import '../local.dart';

const kEnableWebsockets = false;
const kRepositoriesLimit = 5;

class GitHubRepository {
  GitHubRepository({GraphQLClient client}) : _client = client ?? _getClient();

  final GraphQLClient _client;

  Future<List<RepositoryModel>> readRepositories() async {
    final variables = {'nRepositories': kRepositoriesLimit};
    final options = QueryOptions(
      documentNode: _API.readRepositories,
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
    final queryResult =
        await _client.query(options).timeout(kGraphQLQueryTimeoutDuration);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    final dataItems = <Map<String, dynamic>>[
      ...queryResult.data['viewer']['repositories']['nodes']
    ];
    final result = <RepositoryModel>[];
    for (final dataItem in dataItems) {
      result.add(RepositoryModel.fromJson(dataItem));
    }
    return result;
  }

  void toggleStar({String id, bool value}) {}
}

GraphQLClient _getClient() {
  final httpLink = HttpLink(
    uri: 'https://api.github.com/graphql',
  );
  final authLink = AuthLink(
    getToken: () async => 'Bearer $kPersonalAccessToken',
  );
  var link = authLink.concat(httpLink);
  if (kEnableWebsockets) {
    final websocketLink = WebSocketLink(
      url: 'ws://localhost:8080/ws/graphql',
      config: SocketClientConfig(
          autoReconnect: true, inactivityTimeout: const Duration(seconds: 15)),
    );

    link = link.concat(websocketLink);
  }
  return GraphQLClient(
    cache: OptimisticCache(
      dataIdFromObject: typenameDataIdFromObject,
    ),
    link: link,
  );
}

class _API {
  static final fragments = gql(r'''
    fragment RepositoryFields on Repository {
      __typename
      id
      name
      viewerHasStarred
    }
  ''');

  static final readRepositories = gql(r'''
    query ReadRepositories($nRepositories: Int!) {
      viewer {
        repositories(last: $nRepositories) {
          nodes {
            ...RepositoryFields
          }
        }
      }
    }
  ''')..definitions.addAll(fragments.definitions);

  // static final searchRepositories = gql(r'''
  //   query SearchRepositories($nRepositories: Int!, $query: String!, $cursor: String) {
  //     search(last: $nRepositories, query: $query, type: REPOSITORY, after: $cursor) {
  //       nodes {
  //         __typename
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

// const String addStar = r'''
//   mutation AddStar($starrableId: ID!) {
//     action: addStar(input: {starrableId: $starrableId}) {
//       starrable {
//         viewerHasStarred
//       }
//     }
//   }
// ''';

// const String removeStar = r'''
//   mutation RemoveStar($starrableId: ID!) {
//     action: removeStar(input: {starrableId: $starrableId}) {
//       starrable {
//         viewerHasStarred
//       }
//     }
//   }
// ''';

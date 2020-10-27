import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_firebase_login/import.dart';

// ignore: uri_does_not_exist
import '../local.dart';

const kEnableWebsockets = false;
const kRepositoriesLimit = 8;

class GitHubRepository {
  GitHubRepository({GraphQLClient client}) : _client = client ?? _getClient();

  final GraphQLClient _client;

  Future<List<RepositoryModel>> readRepositories() async {
    final queryResult = await _client
        .query(QueryOptions(
          documentNode: _API.readRepositories,
          variables: {'nRepositories': kRepositoriesLimit},
          fetchPolicy: FetchPolicy.noCache,
        ))
        .timeout(kGraphQLQueryTimeoutDuration);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    final dataItems =
        (queryResult.data['viewer']['repositories']['nodes'] as List)
            .cast<Map<String, dynamic>>();
    final result = <RepositoryModel>[];
    for (final dataItem in dataItems) {
      result.add(RepositoryModel.fromJson(dataItem));
    }
    return result;
  }

  Future<bool> toggleStar({String id, bool value}) async {
    final mutationResult = await _client
        .mutate(MutationOptions(
          documentNode: value ? _API.addStar : _API.removeStar,
          variables: {'starrableId': id},
          fetchPolicy: FetchPolicy.noCache,
        ))
        .timeout(kGraphQLQueryTimeoutDuration);
    if (mutationResult.hasException) {
      throw mutationResult.exception;
    }
    return mutationResult.data['action']['starrable']['viewerHasStarred']
        as bool;
  }
}

GraphQLClient _getClient() {
  final httpLink = HttpLink(
    uri: 'https://api.github.com/graphql',
  );
  final authLink = AuthLink(
    getToken: () async => 'Bearer $kGitHubPersonalAccessToken',
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

  static final addStar = gql(r'''
    mutation AddStar($starrableId: ID!) {
      action: addStar(input: {starrableId: $starrableId}) {
        starrable {
          viewerHasStarred
        }
      }
    }
  ''');

  static final removeStar = gql(r'''
    mutation RemoveStar($starrableId: ID!) {
      action: removeStar(input: {starrableId: $starrableId}) {
        starrable {
          viewerHasStarred
        }
      }
    }
  ''');

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

import 'package:graphql/client.dart';
import 'package:flutter_idiomatic/import.dart';

const _kEnableWebsockets = false;
const _kRepositoriesLimit = 8;

class GitHubRepository {
  GitHubRepository({
    GraphQLService service,
  }) : _service = service ??
            GraphQLService(
              client: _createClient(),
              timeout: kGraphQLTimeoutDuration,
            );

  final GraphQLService _service;

  Future<List<RepositoryModel>> readRepositories() async {
    return _service.query<RepositoryModel>(
      documentNode: _API.readRepositories,
      variables: {'nRepositories': _kRepositoriesLimit},
      toRoot: (dynamic rawJson) => rawJson['viewer']['repositories']['nodes'],
      convert: RepositoryModel.fromJson,
    );
  }

  Future<bool> toggleStar({String id, bool value}) async {
    return _service.mutate<bool>(
      documentNode: value ? _API.addStar : _API.removeStar,
      variables: {'starrableId': id},
      toRoot: (dynamic rawJson) => rawJson['action']['starrable'],
      convert: (Map<String, dynamic> json) => json['viewerHasStarred'] as bool,
    );
  }
}

GraphQLClient _createClient() {
  final httpLink = HttpLink(
    uri: 'https://api.github.com/graphql',
  );
  final authLink = AuthLink(
    getToken: () async => 'Bearer $kGitHubPersonalAccessToken',
  );
  var link = authLink.concat(httpLink);
  if (_kEnableWebsockets) {
    final websocketLink = WebSocketLink(
      url: 'ws://localhost:8080/ws/graphql',
      config: SocketClientConfig(
        inactivityTimeout: Duration(seconds: 15),
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

mixin _API {
  static final fragments = gql(r'''
    fragment RepositoryFields on Repository {
      # __typename
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

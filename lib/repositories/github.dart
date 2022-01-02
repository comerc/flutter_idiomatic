import 'package:graphql/client.dart';
import 'package:flutter_idiomatic/import.dart';

const _kEnableWebsockets = false;
const _kRepositoriesLimit = 8;

class GitHubRepository {
  GitHubRepository({
    GraphQLService? service,
  }) : _service = service ??
            GraphQLService(
              client: _createClient(),
              queryTimeout: kGraphQLQueryTimeout,
              mutationTimeout: kGraphQLMutationTimeout,
            );

  final GraphQLService _service;

  Future<List<RepositoryModel>> readRepositories() async {
    return _service.query(
      document: GitHubAPI.readRepositories,
      variables: {'nRepositories': _kRepositoriesLimit},
      // ignore: avoid_dynamic_calls
      toRoot: (dynamic rawJson) => rawJson['viewer']['repositories']['nodes'],
      convert: RepositoryModel.fromJson,
    );
  }

  Future<bool?> toggleStar({required String id, required bool value}) async {
    return _service.mutate(
      document: value ? GitHubAPI.addStar : GitHubAPI.removeStar,
      variables: {'starrableId': id},
      // ignore: avoid_dynamic_calls
      toRoot: (dynamic rawJson) => rawJson['action']['starrable'],
      convert: (Map<String, dynamic> json) => json['viewerHasStarred'] as bool,
    );
  }
}

GraphQLClient _createClient() {
  final httpLink = HttpLink(
    'https://api.github.com/graphql',
  );
  final authLink = AuthLink(
    getToken: () async => 'Bearer $kGitHubPersonalAccessToken',
  );
  var link = authLink.concat(httpLink);
  if (_kEnableWebsockets) {
    final websocketLink = WebSocketLink(
      'ws://localhost:8080/ws/graphql',
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

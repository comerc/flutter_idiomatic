// ignore_for_file: require_trailing_commas
import 'package:graphql/client.dart';

mixin GitHubAPI {
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

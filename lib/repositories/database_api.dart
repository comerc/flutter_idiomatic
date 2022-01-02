// ignore_for_file: require_trailing_commas
import 'package:graphql/client.dart';

mixin DatabaseAPI {
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

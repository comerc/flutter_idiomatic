import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

T getBloc<T extends Cubit<Object>>(BuildContext context) =>
    BlocProvider.of<T>(context);

T getRepository<T>(BuildContext context) => RepositoryProvider.of<T>(context);

/// boilerplate `result.loading` and `result.hasException` handling
///
/// ```dart
/// if (result.hasException) {
///   return Text(result.exception.toString());
/// }
/// if (result.loading) {
///   return Center(
///     child: CircularProgressIndicator(),
///   );
/// }
/// ```
QueryBuilder withGenericHandling(QueryBuilder builder) {
  return (result, {fetchMore, refetch}) {
    if (result.hasException) {
      return Text(result.exception.toString());
    }
    if (result.loading && result.data == null) {
      return Center(
        child: CircularProgressIndicator(), // buildProgressIndicator(context),
      );
    }
    if (result.data == null && !result.hasException) {
      return Text(
          'Both data and errors are null, this is a known bug after refactoring');
    }
    return builder(result, fetchMore: fetchMore, refetch: refetch);
  };
}

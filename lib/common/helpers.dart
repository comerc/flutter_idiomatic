import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

T getBloc<T extends Cubit<Object>>(BuildContext context) =>
    BlocProvider.of<T>(context);

T getRepository<T>(BuildContext context) => RepositoryProvider.of<T>(context);

void out(dynamic value) {
  if (kDebugMode) debugPrint('$value');
}

class ValidationException implements Exception {
  ValidationException(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}

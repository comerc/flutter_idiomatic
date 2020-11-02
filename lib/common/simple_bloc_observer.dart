import 'package:bloc/bloc.dart';
import 'package:flutter_firebase_login/import.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    out(error);
    super.onError(cubit, error, stackTrace);
  }

  @override
  void onChange(Cubit cubit, Change change) {
    out(change);
    super.onChange(cubit, change);
  }
}

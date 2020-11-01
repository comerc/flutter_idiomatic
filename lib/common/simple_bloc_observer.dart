import 'package:bloc/bloc.dart';
import 'package:flutter_firebase_login/import.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    out(event);
    super.onEvent(bloc, event);
  }

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

  @override
  void onTransition(Bloc bloc, Transition transition) {
    out(transition);
    super.onTransition(bloc, transition);
  }
}

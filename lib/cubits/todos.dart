import 'dart:async';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_firebase_login/import.dart';

part 'todos.g.dart';

class TodosCubit extends Cubit<TodosState> {
  TodosCubit(this.repository)
      : assert(repository != null),
        super(TodosState()) {
    _fetchNewNotificationSubscription =
        repository.fetchNewTodoNotification.listen(fetchNewNotification);
  }

  final DatabaseRepository repository;
  StreamSubscription<int> _fetchNewNotificationSubscription;
  bool _isStartedSubscription = false;

  @override
  Future<void> close() {
    _fetchNewNotificationSubscription?.cancel();
    return super.close();
  }

  void fetchNewNotification(int id) {
    if (!_isStartedSubscription) {
      _isStartedSubscription = true;
      return;
    }
    emit(state.copyWith(newId: id));
  }

  Future<void> load({TodosOrigin origin = TodosOrigin.start}) async {
    const kLimit = 10;
    if (state.status == TodosStatus.loading) return;
    emit(state.copyWith(
      status: TodosStatus.loading,
      origin: origin,
      loadingError: '',
    ));
    try {
      final items = await repository.readTodos(
        createdAt: origin == TodosOrigin.loadMore ? state.nextDateTime : null,
        limit: kLimit + 1,
      );
      var hasMore = false;
      DateTime nextDateTime;
      if (items.length == kLimit + 1) {
        hasMore = true;
        final lastItem = items.removeLast();
        nextDateTime = lastItem.createdAt;
      }
      if (origin != TodosOrigin.loadMore) {
        emit(TodosState());
        await Future.delayed(Duration(milliseconds: 300));
      }
      emit(state.copyWith(
        items: [...state.items, ...items],
        hasMore: hasMore,
        nextDateTime: nextDateTime,
      ));
    } on Exception {
      emit(state.copyWith(loadingError: 'Can not load todos'));
    } finally {
      emit(state.copyWith(
        status: TodosStatus.ready,
        origin: TodosOrigin.initial,
      ));
    }
  }

  Future<bool> remove(int id) async {
    emit(state.copyWith(
      items: [...state.items]..removeWhere((TodoModel item) => item.id == id),
    ));
    try {
      final deletedId = await repository.deleteTodo(id);
      if (deletedId != id) {
        throw Exception('Can not remove todo $id');
      }
    } on Exception {
      return false;
    }
    return true;
  }

  Future<bool> add(String title) async {
    final titleInput = TitleInputModel.dirty(title);
    final status = Formz.validate([titleInput]);
    if (status.isInvalid) {
      throw titleInput.error;
    }
    emit(state.copyWith(isSubmitMode: true));
    try {
      final item = await repository.createTodo(titleInput.value);
      emit(state.copyWith(
        items: [item, ...state.items],
      ));
    } on Exception {
      return false;
    } finally {
      emit(state.copyWith(isSubmitMode: false));
    }
    return true;
  }
}

enum TodosStatus { initial, loading, ready }
enum TodosOrigin { initial, start, refreshIndicator, loadNew, loadMore }

@CopyWith()
class TodosState extends Equatable {
  TodosState({
    this.items = const [],
    this.status = TodosStatus.initial,
    this.origin = TodosOrigin.initial,
    this.loadingError = '',
    this.hasMore = false,
    this.nextDateTime,
    this.newId,
    this.isSubmitMode = false,
  });

  final List<TodoModel> items;
  final TodosStatus status;
  final TodosOrigin origin;
  final String loadingError;
  final DateTime nextDateTime;
  final bool hasMore;
  final int newId;
  final bool isSubmitMode;

  bool get hasReallyNewId =>
      newId != null &&
      items.indexWhere((TodoModel item) => item.id == newId) == -1;

  @override
  List<Object> get props => [
        items,
        status,
        origin,
        loadingError,
        hasMore,
        nextDateTime,
        newId,
        isSubmitMode,
      ];
}

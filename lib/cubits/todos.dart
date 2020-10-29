import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_firebase_login/import.dart';

class TodosCubit extends Cubit<TodosState> {
  TodosCubit(this.databaseRepository)
      : assert(databaseRepository != null),
        super(const TodosState()) {
    _fetchNewTodoNotificationSubscription = databaseRepository
        .fetchNewTodoNotification
        .listen(fetchNewTodoNotification);
  }

  final DatabaseRepository databaseRepository;
  StreamSubscription<int> _fetchNewTodoNotificationSubscription;
  bool isStartedSubscription = false;

  @override
  Future<void> close() {
    _fetchNewTodoNotificationSubscription?.cancel();
    return super.close();
  }

  void fetchNewTodoNotification(int id) {
    if (!isStartedSubscription) {
      isStartedSubscription = true;
      return;
    }
    emit(state.copyWith(newId: id));
  }

  Future<bool> load({bool isRefresh = false}) async {
    const kLimit = 10;
    var result = true;
    emit(state.copyWith(status: TodosStatus.busy));
    try {
      final items = await databaseRepository.readTodos(
        createdAt: isRefresh ? null : state.nextDateTime,
        limit: kLimit + 1,
      );
      var hasMore = false;
      DateTime nextDateTime;
      if (items.length == kLimit + 1) {
        hasMore = true;
        final lastItem = items.removeLast();
        nextDateTime = lastItem.createdAt;
      }
      if (isRefresh) {
        emit(const TodosState());
        await Future.delayed(const Duration(milliseconds: 300));
      }
      emit(state.copyWith(
        items: [...state.items, ...items],
        status: TodosStatus.ready,
        hasMore: hasMore,
        nextDateTime: nextDateTime,
      ));
    } catch (error) {
      result = false;
    }
    return result;
  }

  Future<bool> remove(int id) async {
    var result = true;
    emit(
      state.copyWith(
        items: [...state.items..removeWhere((TodoModel item) => item.id == id)],
      ),
    );
    try {
      final deletedId = await databaseRepository.deleteTodo(id);
      if (deletedId != id) {
        throw 'Can not remove todo $id';
      }
    } catch (error) {
      result = false;
    }
    return result;
  }
}

enum TodosStatus { initial, busy, ready }

class TodosState extends Equatable {
  const TodosState({
    this.items = const [],
    this.status = TodosStatus.initial,
    this.hasMore = false,
    this.nextDateTime,
    this.newId,
  }) : assert(items != null);

  final List<TodoModel> items;
  final TodosStatus status;
  final DateTime nextDateTime;
  final bool hasMore;
  final int newId;

  bool get hasReallyNewId =>
      newId != null &&
      items.indexWhere((TodoModel item) => item.id == newId) == -1;

  @override
  List<Object> get props => [items, status, hasMore, nextDateTime, newId];

  TodosState copyWith({
    List<TodoModel> items,
    TodosStatus status,
    bool hasMore,
    DateTime nextDateTime,
    int newId,
  }) {
    return TodosState(
      items: items ?? this.items,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
      nextDateTime: nextDateTime ?? this.nextDateTime,
      newId: newId ?? this.newId,
    );
  }
}

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_firebase_login/import.dart';

class MyTodosCubit extends Cubit<MyTodosState> {
  MyTodosCubit(this.databaseRepository)
      : assert(databaseRepository != null),
        super(const MyTodosState()) {
    _fetchNewNotificationSubscription =
        databaseRepository.fetchNewNotification.listen(fetchNewNotification);
  }

  final DatabaseRepository databaseRepository;
  StreamSubscription<int> _fetchNewNotificationSubscription;
  bool isStartedSubscription = false;

  @override
  Future<void> close() {
    _fetchNewNotificationSubscription?.cancel();
    return super.close();
  }

  void fetchNewNotification(int id) {
    if (!isStartedSubscription) {
      isStartedSubscription = true;
      return;
    }
    emit(state.copyWith(newId: id));
  }

  Future<bool> load({bool isRefresh = false}) async {
    const kLimit = 10;
    var result = true;
    emit(state.copyWith(status: MyTodosStatus.busy));
    try {
      final items = await databaseRepository.readMyTodos(
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
        emit(const MyTodosState());
        await Future.delayed(const Duration(milliseconds: 300));
      }
      emit(state.copyWith(
        items: [...state.items, ...items],
        status: MyTodosStatus.ready,
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

enum MyTodosStatus { initial, busy, ready }

class MyTodosState extends Equatable {
  const MyTodosState({
    this.items = const [],
    this.status = MyTodosStatus.initial,
    this.hasMore = false,
    this.nextDateTime,
    this.newId,
  }) : assert(items != null);

  final List<TodoModel> items;
  final MyTodosStatus status;
  final DateTime nextDateTime;
  final bool hasMore;
  final int newId;

  bool get hasReallyNewId =>
      newId != null &&
      items.indexWhere((TodoModel item) => item.id == newId) == -1;

  @override
  List<Object> get props => [items, status, hasMore, nextDateTime, newId];

  MyTodosState copyWith({
    List<TodoModel> items,
    MyTodosStatus status,
    bool hasMore,
    DateTime nextDateTime,
    int newId,
  }) {
    return MyTodosState(
      items: items ?? this.items,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
      nextDateTime: nextDateTime ?? this.nextDateTime,
      newId: newId ?? this.newId,
    );
  }
}

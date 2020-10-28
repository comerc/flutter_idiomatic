import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_firebase_login/import.dart';

class MyTodosCubit extends Cubit<MyTodosState> {
  MyTodosCubit(this.databaseRepository)
      : assert(databaseRepository != null),
        super(const MyTodosState());

  final DatabaseRepository databaseRepository;

  Future<bool> load({bool isRefresh = false}) async {
    const kLimit = 4;
    var result = true;
    emit(state.copyWith(status: MyTodosStatus.busy));
    try {
      final items = await databaseRepository.readMyTodos(
        createdAt: isRefresh ? null : state.nextDateTime,
        limit: kLimit + 1,
      );
      DateTime nextDateTime;
      if (items.length == kLimit + 1) {
        final lastItem = items.removeLast();
        nextDateTime = lastItem.createdAt;
      }
      if (isRefresh) {
        emit(const MyTodosState());
        await Future.delayed(const Duration(milliseconds: 300));
      }
      emit(MyTodosState(
        items: [...state.items, ...items],
        status: MyTodosStatus.ready,
        nextDateTime: nextDateTime,
      ));
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
    this.nextDateTime,
  }) : assert(items != null);

  final List<TodoModel> items;
  final MyTodosStatus status;
  final DateTime nextDateTime;

  @override
  List<Object> get props => [items, status, nextDateTime];

  MyTodosState copyWith({
    List<TodoModel> items,
    MyTodosStatus status,
    DateTime nextDateTime,
  }) {
    return MyTodosState(
      items: items ?? this.items,
      status: status ?? this.status,
      nextDateTime: nextDateTime ?? this.nextDateTime,
    );
  }
}

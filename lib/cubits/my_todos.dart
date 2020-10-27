import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_firebase_login/import.dart';

class MyTodosCubit extends Cubit<MyTodosState> {
  MyTodosCubit(this.databaseRepository)
      : assert(databaseRepository != null),
        super(const MyTodosState());

  final DatabaseRepository databaseRepository;

  Future<bool> load() async {
    var result = true;
    emit(state.copyWith(status: MyTodosStatus.busy));
    try {
      final items = await databaseRepository.readMyTodos();
      emit(const MyTodosState());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(state.copyWith(
        items: items,
        status: MyTodosStatus.ready,
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
  }) : assert(items != null);

  final List<TodoModel> items;
  final MyTodosStatus status;

  @override
  List<Object> get props => [items, status];

  MyTodosState copyWith({
    List<TodoModel> items,
    MyTodosStatus status,
  }) {
    return MyTodosState(
      items: items ?? this.items,
      status: status ?? this.status,
    );
  }
}

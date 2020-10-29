import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/import.dart';

class TodosScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/my_todos',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Todos')),
      body: BlocProvider(
        create: (BuildContext context) {
          final cubit = TodosCubit(getRepository<DatabaseRepository>(context));
          _load(cubit);
          return cubit;
        },
        child: TodosBody(),
      ),
    );
  }

  static Future<void> _load(TodosCubit cubit, {bool isRefresh = false}) async {
    final result = await cubit.load(isRefresh: isRefresh);
    if (result) return;
    BotToast.showNotification(
      title: (_) => const Text(
        'Can not load my todos',
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      trailing: (Function close) => FlatButton(
        onLongPress: () {}, // чтобы сократить время для splashColor
        onPressed: () {
          close();
          _load(cubit, isRefresh: isRefresh);
        },
        child: const Text('REPEAT'),
      ),
    );
  }
}

class TodosBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        return TodosScreen._load(
          getBloc<TodosCubit>(context),
          isRefresh: true,
        );
      },
      child: BlocBuilder<TodosCubit, TodosState>(
        builder: (BuildContext context, TodosState state) {
          return Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Add new Todo',
                      ),
                      onSubmitted: (value) => print('changeQuery $value'),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.items.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == state.items.length) {
                          if (state.status == TodosStatus.busy) {
                            return Center(
                                child: const CircularProgressIndicator());
                          }
                          if (state.status == TodosStatus.ready) {
                            if (state.hasMore) {
                              return Center(
                                child: FlatButton(
                                    child: Text(
                                      'LOAD MORE',
                                      style:
                                          TextStyle(color: theme.primaryColor),
                                    ),
                                    shape: StadiumBorder(),
                                    onPressed: () {
                                      // TODO: load new items in AnimatedList
                                      TodosScreen._load(
                                        getBloc<TodosCubit>(context),
                                      );
                                    }),
                              );
                            }
                            return Column(
                              children: [
                                Text(state.items.isEmpty
                                    ? 'NO DATA'
                                    : 'NO MORE'),
                                const SizedBox(height: 8),
                              ],
                            );
                          }
                          return Container();
                        }
                        final item = state.items[index];
                        return Dismissible(
                          key: Key('${item.id}'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (DismissDirection direction) {
                            _remove(getBloc<TodosCubit>(context), id: item.id);
                          },
                          background: Container(
                            color: Colors.red,
                            child: Row(children: <Widget>[
                              const Spacer(),
                              const Icon(Icons.delete_outline),
                              const SizedBox(width: 8),
                            ]),
                          ),
                          child: TodosItem(
                            item: item,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (state.hasReallyNewId)
                Positioned(
                  top: 56,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: RaisedButton(
                      shape: StadiumBorder(),
                      color: theme.accentColor,
                      onPressed: () {
                        getBloc<TodosCubit>(context).load(isRefresh: true);
                      },
                      child: Text(
                        'LOAD NEW',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _remove(TodosCubit cubit, {int id}) async {
    final result = await cubit.remove(id);
    if (result) return; // TODO: undo
    BotToast.showNotification(
      title: (_) => Text(
        'Can not remove todo $id',
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      trailing: (Function close) => FlatButton(
        onLongPress: () {}, // чтобы сократить время для splashColor
        onPressed: () {
          close();
          _remove(cubit, id: id);
        },
        child: const Text('REPEAT'),
      ),
    );
  }
}

class TodosItem extends StatelessWidget {
  const TodosItem({
    Key key,
    this.item,
  }) : super(key: key);

  final TodoModel item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${item.id} ${item.title}'),
    );
  }
}

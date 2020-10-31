import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/import.dart';

class TodosScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/todos',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: BlocProvider(
        create: (BuildContext context) {
          final cubit = TodosCubit(getRepository<DatabaseRepository>(context));
          _load(cubit, indicator: TodosIndicator.start);
          return cubit;
        },
        child: TodosBody(),
      ),
    );
  }

  static Future<void> _load(
    TodosCubit cubit, {
    bool isRefresh = false,
    TodosIndicator indicator,
  }) async {
    final result = await cubit.load(
      isRefresh: isRefresh,
      indicator: indicator,
    );
    if (result) return;
    BotToast.showNotification(
      title: (_) => const Text(
        'Can not load todos',
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      trailing: (Function close) => FlatButton(
        onLongPress: () {}, // чтобы сократить время для splashColor
        onPressed: () {
          close();
          _load(
            cubit,
            isRefresh: isRefresh,
            indicator: indicator,
          );
        },
        child: Text('Repeat'.toUpperCase()),
      ),
    );
  }
}

class TodosBody extends StatelessWidget {
  final _inputKey = GlobalKey<_InputState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodosCubit, TodosState>(
      listenWhen: (TodosState previous, TodosState current) {
        return previous.isSubmitMode != current.isSubmitMode;
      },
      listener: (BuildContext context, TodosState state) {
        if (state.isSubmitMode) {
          showDialog(
            context: context,
            barrierDismissible: false,
            child: AlertDialog(
              content: Row(
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  const Text('Loading...'),
                ],
              ),
            ),
          );
        } else {
          navigator.pop();
        }
      },
      // buildWhen: (TodosState previous, TodosState current) {
      //   return !current.isSubmitMode; // TODO: how about newId ?
      // },
      builder: (BuildContext context, TodosState state) {
        return Stack(
          children: <Widget>[
            RefreshIndicator(
              onRefresh: () async {
                return TodosScreen._load(
                  getBloc<TodosCubit>(context),
                  isRefresh: true,
                  indicator: TodosIndicator.refreshIndicator,
                );
              },
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: _Input(
                      key: _inputKey,
                      onSubmitted: (String value) {
                        _add(getBloc<TodosCubit>(context), title: value);
                      },
                    ),
                  ),
                  if (state.indicator == TodosIndicator.initial)
                    const Spacer()
                  else if (state.indicator == TodosIndicator.start)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.indicator == TodosIndicator.loadMore
                            ? state.items.length + 1
                            : state.items.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == state.items.length) {
                            if (state.status == TodosStatus.busy) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (state.status == TodosStatus.ready) {
                              if (state.hasMore) {
                                return Center(
                                  child: FlatButton(
                                      child: Text(
                                        'Load More'.toUpperCase(),
                                        style: TextStyle(
                                            color: theme.primaryColor),
                                      ),
                                      shape: const StadiumBorder(),
                                      onPressed: () {
                                        TodosScreen._load(
                                          getBloc<TodosCubit>(context),
                                          indicator: TodosIndicator.loadMore,
                                        );
                                      }),
                                );
                              }
                              return Column(
                                children: [
                                  Text(state.items.isEmpty
                                      ? 'No Data'.toUpperCase()
                                      : 'No More'.toUpperCase()),
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
                              _remove(getBloc<TodosCubit>(context),
                                  id: item.id);
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
            ),
            if (state.hasReallyNewId)
              Positioned(
                top: 56,
                left: 0,
                right: 0,
                child: Center(
                  child: RaisedButton(
                    shape: const StadiumBorder(),
                    color: theme.accentColor,
                    onPressed: () {
                      // TODO: load new items in AnimatedList
                      getBloc<TodosCubit>(context).load(
                        isRefresh: true,
                        indicator: TodosIndicator.loadNew,
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.indicator == TodosIndicator.loadNew) ...[
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            width: 20,
                            height: 20,
                            child:
                                const CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                        ],
                        Text(
                          'Load New'.toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _remove(TodosCubit cubit, {int id}) async {
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
        child: Text('Repeat'.toUpperCase()),
      ),
    );
  }

  Future<void> _add(TodosCubit cubit, {String title}) async {
    final result = await cubit.add(title).catchError((error) {
      BotToast.showNotification(
        title: (_) => Text(
          '$error',
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
      );
      return false;
    });
    if (result) {
      _inputKey.currentState?.controller?.clear();
      return;
    }
    BotToast.showNotification(
      title: (_) => Text(
        'Can not add todo "$title"',
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      trailing: (Function close) => FlatButton(
        onLongPress: () {}, // чтобы сократить время для splashColor
        onPressed: () {
          close();
          _add(cubit, title: title);
        },
        child: Text('Repeat'.toUpperCase()),
      ),
    );
  }
}

class _Input extends StatefulWidget {
  const _Input({
    Key key,
    this.onSubmitted,
  }) : super(key: key);

  final ValueChanged<String> onSubmitted;

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<_Input> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Add new Todo',
        // helperText: '',
        // errorText: null,
      ),
      onSubmitted: widget.onSubmitted,
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
      title: Text('${item.title}'),
    );
  }
}

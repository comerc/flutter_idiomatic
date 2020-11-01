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
  final _listKey = GlobalKey<AnimatedListState>();

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
                children: const <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Loading...'),
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
                  const Divider(height: 1),
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
                      child: AnimatedList(
                        key: _listKey,
                        initialItemCount:
                            state.indicator == TodosIndicator.loadMore
                                ? state.items.length + 1
                                : state.items.length,
                        itemBuilder: _buildItem(state),
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
                  child: _LoadNewButton(state: state),
                ),
              ),
          ],
        );
      },
    );
  }

  AnimatedListItemBuilder _buildItem(TodosState state) {
    return (
      BuildContext context,
      int index,
      Animation<double> animation,
    ) {
      if (index == state.items.length) {
        return _Footer(state: state);
      }
      final item = state.items[index];
      return Dismissible(
        key: Key('${item.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (DismissDirection direction) {
          _listKey.currentState.removeItem(
              index,
              (BuildContext context, Animation<double> animation) =>
                  Container(),
              duration: const Duration());
          _remove(getBloc<TodosCubit>(context), id: item.id);
        },
        background: Container(
          color: Colors.red,
          child: Row(children: const <Widget>[
            Spacer(),
            Icon(Icons.delete_outline),
            SizedBox(width: 8),
          ]),
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              builder: (BuildContext context, Widget child) {
                return ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: animation.value,
                    child: child,
                  ),
                );
              },
              animation: animation,
              child: _Item(
                item: item,
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      );
    };
  }

  Future<void> _remove(TodosCubit cubit, {int id}) async {
    final result = await cubit.remove(id);
    if (result) return;
    // TODO: undo https://stackoverflow.com/questions/53175605/flutter-dismissible-undo-animation-using-animatedlist
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
    var hasError = false;
    final result = await cubit.add(title).catchError((error) {
      BotToast.showNotification(
        title: (_) => Text(
          '$error',
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
      );
      hasError = true;
    });
    if (hasError) {
      return;
    }
    if (result) {
      _listKey.currentState?.insertItem(0);
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

class _LoadNewButton extends StatelessWidget {
  const _LoadNewButton({
    Key key,
    this.state,
  }) : super(key: key);

  final TodosState state;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: const StadiumBorder(),
      color: theme.accentColor,
      onPressed: (state.status == TodosStatus.busy)
          ? null
          : () {
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
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            'Load New'.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ],
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

class _Item extends StatelessWidget {
  const _Item({
    Key key,
    this.item,
  }) : super(key: key);

  final TodoModel item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.title),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    Key key,
    @required this.state,
  }) : super(key: key);

  final TodosState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == TodosStatus.busy &&
        state.indicator == TodosIndicator.loadMore) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == TodosStatus.ready) {
      if (state.hasMore) {
        return Center(
          child: FlatButton(
            shape: const StadiumBorder(),
            onPressed: () {
              TodosScreen._load(
                getBloc<TodosCubit>(context),
                indicator: TodosIndicator.loadMore,
              );
            },
            child: Text(
              'Load More'.toUpperCase(),
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
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
}

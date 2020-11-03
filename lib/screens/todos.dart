import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart' show timeDilation;
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
      appBar: AppBar(title: Text('Todos')),
      body: BlocProvider(
        create: (BuildContext context) =>
            TodosCubit(getRepository<DatabaseRepository>(context))..load(),
        child: TodosBody(),
      ),
    );
  }
}

class TodosBody extends StatefulWidget {
  @override
  _TodosBodyState createState() => _TodosBodyState();
}

class _TodosBodyState extends State<TodosBody> {
  final _inputKey = GlobalKey<_InputState>();
  final _listKey = GlobalKey<AnimatedListState>();
  final _controller = ScrollController();
  int _loadMoreItemsLength = 0;

  @override
  void initState() {
    super.initState();
    // timeDilation = 10.0; // Will slow down animations by a factor of two
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TodosCubit, TodosState>(
          listenWhen: (TodosState previous, TodosState current) {
            return previous.loadingError != current.loadingError &&
                current.loadingError.isNotEmpty;
          },
          listener: (BuildContext context, TodosState state) {
            BotToast.showNotification(
              title: (_) => Text(
                state.loadingError,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              trailing: (Function close) => FlatButton(
                onLongPress: () {}, // чтобы сократить время для splashColor
                onPressed: () {
                  close();
                  getBloc<TodosCubit>(context).load(
                    origin: state.origin,
                  );
                },
                child: Text('Repeat'.toUpperCase()),
              ),
            );
          },
        ),
        BlocListener<TodosCubit, TodosState>(
          listenWhen: (TodosState previous, TodosState current) {
            return previous.isSubmitMode != current.isSubmitMode;
          },
          listener: (BuildContext context, TodosState state) {
            if (state.isSubmitMode) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
          },
        ),
        BlocListener<TodosCubit, TodosState>(
          listenWhen: (TodosState previous, TodosState current) {
            if (current.isSubmitMode) {
              return false;
            }
            if (current.origin == TodosOrigin.loadMore &&
                previous.items.length < current.items.length) {
              _loadMoreItemsLength =
                  current.items.length - previous.items.length;
              return true;
            }
            return false;
          },
          listener: (BuildContext context, TodosState state) {
            final insertIndex = state.items.length - _loadMoreItemsLength;
            for (int offset = 0; offset < _loadMoreItemsLength; offset++) {
              _listKey.currentState
                  .insertItem(insertIndex + offset, duration: Duration.zero);
            }
          },
        ),
      ],
      child: BlocBuilder<TodosCubit, TodosState>(
        // buildWhen: (TodosState previous, TodosState current) {
        //   return !current.isSubmitMode; // TODO: how about hasReallyNewId ?
        // },
        builder: (BuildContext context, TodosState state) {
          return Stack(
            children: <Widget>[
              RefreshIndicator(
                onRefresh: () async {
                  return getBloc<TodosCubit>(context).load(
                    origin: TodosOrigin.refreshIndicator,
                  );
                },
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: _Input(
                        key: _inputKey,
                        onSubmitted: (String value) {
                          _add(getBloc<TodosCubit>(context), title: value);
                        },
                      ),
                    ),
                    Divider(height: 1),
                    if (state.status == TodosStatus.initial)
                      Spacer()
                    else if (state.origin == TodosOrigin.start)
                      Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Expanded(
                        child: AnimatedList(
                          key: _listKey,
                          controller: _controller,
                          // HACK: https://github.com/flutter/flutter/issues/22180#issuecomment-478080997
                          physics: AlwaysScrollableScrollPhysics(),
                          initialItemCount: state.items.length + 1,
                          itemBuilder: _buildItem(state),
                        ),
                      ),
                  ],
                ),
              ),
              if (state.hasReallyNewId)
                Positioned(
                  top: 56, // TODO: calculate
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _LoadNewButton(state: state),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  AnimatedListItemBuilder _buildItem(TodosState state) {
    return (
      BuildContext context,
      int index,
      Animation<double> animation,
    ) {
      if (index == state.items.length) {
        return _Footer(
          state: state,
          onPressed: () {
            getBloc<TodosCubit>(context).load(
              origin: TodosOrigin.loadMore,
            );
          },
        );
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
              duration: Duration.zero);
          _remove(getBloc<TodosCubit>(context), id: item.id);
        },
        background: Container(
          color: Colors.redAccent,
          child: Row(children: <Widget>[
            Spacer(),
            Icon(
              Icons.delete_outline,
              color: Colors.white,
            ),
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
              child: ListTile(
                title: Text('$index of ${state.items.length} - ${item.title}'),
              ),
              // _Item(
              //   item: item,
              // ),
            ),
            Divider(height: 1),
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
    if (hasError) return;
    if (result) {
      const kDuration = Duration(milliseconds: 300);
      // ignore: unawaited_futures
      _controller.animateTo(
        0,
        duration: kDuration,
        curve: Curves.easeOut,
      );
      // ignore: avoid_redundant_argument_values
      _listKey.currentState?.insertItem(0, duration: kDuration);
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

  void _onScroll() {
    if (_isBottom) {
      final cubit = getBloc<TodosCubit>(context);
      if (cubit.state.hasMore) {
        cubit.load(origin: TodosOrigin.loadMore);
      }
    }
  }

  bool get _isBottom {
    if (!_controller.hasClients) return false;
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}

class _LoadNewButton extends StatelessWidget {
  _LoadNewButton({
    Key key,
    this.state,
  }) : super(key: key);

  final TodosState state;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: StadiumBorder(),
      color: theme.accentColor,
      onPressed: (state.status == TodosStatus.loading)
          ? null
          : () {
              getBloc<TodosCubit>(context).load(
                origin: TodosOrigin.loadNew,
              );
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.origin == TodosOrigin.loadNew) ...[
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
          ],
          Text(
            'Load New'.toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Input extends StatefulWidget {
  _Input({
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
      decoration: InputDecoration(
        labelText: 'Add new Todo',
        // helperText: '',
        // errorText: null,
      ),
      onSubmitted: widget.onSubmitted,
    );
  }
}

// class _Item extends StatelessWidget {
//   _Item({
//     Key key,
//     this.item,
//   }) : super(key: key);

//   final TodoModel item;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(item.title),
//     );
//   }
// }

class _Footer extends StatelessWidget {
  _Footer({
    Key key,
    this.state,
    this.onPressed,
  }) : super(key: key);

  final TodosState state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (state.status == TodosStatus.loading &&
        state.origin == TodosOrigin.loadMore) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (state.status == TodosStatus.ready) {
      if (state.hasMore) {
        return Center(
          child: FlatButton(
            shape: StadiumBorder(),
            onPressed: onPressed,
            child: Text(
              'Load More'.toUpperCase(),
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        );
      }
      return Column(
        children: [
          SizedBox(height: 16),
          Text(state.items.isEmpty
              ? 'No Data'.toUpperCase()
              : 'No More'.toUpperCase()),
          SizedBox(height: 32),
        ],
      );
    }
    return Container();
  }
}

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_idiomatic/import.dart';

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
            TodosCubit(getRepository<DatabaseRepository>(context)),
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
  final _inputKey = GlobalKey<FormFieldState<String>>();
  final _listKey = GlobalKey<AnimatedListState>();
  final _controller = ScrollController();
  int _loadMoreItemsLength = 0;

  @override
  void initState() {
    super.initState();
    load(() => getBloc<TodosCubit>(context).load(origin: TodosOrigin.start));
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
        // BlocListener<TodosCubit, TodosState>(
        //   listenWhen: (TodosState previous, TodosState current) {
        //     return previous.errorMessage != current.errorMessage &&
        //         current.errorMessage.isNotEmpty;
        //   },
        //   listener: (BuildContext context, TodosState state) {
        //     BotToast.showNotification(
        //       title: (_) => Text(
        //         state.errorMessage,
        //         overflow: TextOverflow.fade,
        //         softWrap: false,
        //       ),
        //       trailing: (Function close) => FlatButton(
        //         onLongPress: () {}, // чтобы сократить время для splashColor
        //         onPressed: () {
        //           close();
        //           getBloc<TodosCubit>(context).load(
        //             origin: state.origin,
        //           );
        //         },
        //         child: Text('Repeat'.toUpperCase()),
        //       ),
        //     );
        //   },
        // ),
        // BlocListener<TodosCubit, TodosState>(
        //   listenWhen: (TodosState previous, TodosState current) {
        //     return previous.isSubmitMode != current.isSubmitMode;
        //   },
        //   listener: (BuildContext context, TodosState state) {
        //     if (state.isSubmitMode) {
        //       BotToast.showLoading();
        //     } else {
        //       BotToast.closeAllLoading();
        //     }
        //   },
        // ),
        BlocListener<TodosCubit, TodosState>(
          listenWhen: (TodosState previous, TodosState current) {
            // if (current.isSubmitMode) {
            //   return false;
            // }
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
                onRefresh: () => load(() => getBloc<TodosCubit>(context)
                    .load(origin: TodosOrigin.refreshIndicator)),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: TextFormField(
                        key: _inputKey,
                        decoration: InputDecoration(
                          labelText: 'Add new Todo',
                          // helperText: '',
                          // errorText: null,
                        ),
                        onFieldSubmitted: (String value) {
                          final data = TodosData(title: value.trim());
                          _add(getBloc<TodosCubit>(context), data);
                        },
                      ),
                      // child: _Input(
                      //   key: _inputKey,
                      //   onSubmitted: (String value) {
                      //     final data = TodosData(title: value.trim());
                      //     _add(getBloc<TodosCubit>(context), data);
                      //   },
                      // ),
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
            load(() => getBloc<TodosCubit>(context)
                .load(origin: TodosOrigin.loadMore));
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
                title: Text(
                    '${index + 1} of ${state.items.length} - ${item.title}'),
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
    try {
      await cubit.remove(id);
    } on Exception {
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
  }

  Future<void> _add(TodosCubit cubit, TodosData data) async {
    BotToast.showLoading();
    try {
      await cubit.add(data);
    } on ValidationException catch (error) {
      BotToast.showNotification(
        title: (_) => Text(
          '$error',
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
      );
      return;
    } on Exception {
      BotToast.showNotification(
        title: (_) => Text(
          'Can not add todo "${data.title}"',
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        trailing: (Function close) => FlatButton(
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            close();
            _add(cubit, data);
          },
          child: Text('Repeat'.toUpperCase()),
        ),
      );
      return;
    } finally {
      BotToast.closeAllLoading();
    }
    const kDuration = Duration(milliseconds: 300);
    // ignore: unawaited_futures
    _controller.animateTo(
      0,
      duration: kDuration,
      curve: Curves.easeOut,
    );
    // ignore: avoid_redundant_argument_values
    _listKey.currentState?.insertItem(0, duration: kDuration);
    _inputKey.currentState?.reset();
    // _inputKey.currentState?.controller?.clear();
  }

  void _onScroll() {
    if (_isBottom) {
      final cubit = getBloc<TodosCubit>(context);
      if (cubit.state.hasMore) {
        load(() => cubit.load(origin: TodosOrigin.loadMore));
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
              load(() => getBloc<TodosCubit>(context)
                  .load(origin: TodosOrigin.loadNew));
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

// class _Input extends StatefulWidget {
//   _Input({
//     Key key,
//     this.onSubmitted,
//   }) : super(key: key);

//   final ValueChanged<String> onSubmitted;

//   @override
//   _InputState createState() => _InputState();
// }

// class _InputState extends State<_Input> {
//   final controller = TextEditingController();

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: 'Add new Todo',
//         // helperText: '',
//         // errorText: null,
//       ),
//       onSubmitted: widget.onSubmitted,
//     );
//   }
// }

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

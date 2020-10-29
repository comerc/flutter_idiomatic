import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/import.dart';

class MyTodosScreen extends StatelessWidget {
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
          final cubit =
              MyTodosCubit(getRepository<DatabaseRepository>(context));
          _load(cubit);
          return cubit;
        },
        child: MyTodosBody(),
      ),
    );
  }

  static Future<void> _load(MyTodosCubit cubit,
      {bool isRefresh = false}) async {
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

class MyTodosBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        return MyTodosScreen._load(
          getBloc<MyTodosCubit>(context),
          isRefresh: true,
        );
      },
      child: BlocBuilder<MyTodosCubit, MyTodosState>(
        builder: (BuildContext context, MyTodosState state) {
          return Stack(
            children: [
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
                          if (state.status == MyTodosStatus.busy) {
                            return Center(
                                child: const CircularProgressIndicator());
                          }
                          if (state.status == MyTodosStatus.ready) {
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
                                      MyTodosScreen._load(
                                        getBloc<MyTodosCubit>(context),
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
                        return MyTodosItem(
                          key: Key('${item.id}'),
                          item: item,
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
                        getBloc<MyTodosCubit>(context).loadNew();
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
}

class MyTodosItem extends StatelessWidget {
  const MyTodosItem({
    Key key,
    this.item,
    // this.isLoading,
  }) : super(key: key);

  final TodoModel item;
  // final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // leading: repository.viewerHasStarred
      //     ? const Icon(
      //         Icons.star,
      //         color: Colors.amber,
      //       )
      //     : const Icon(Icons.star_border),
      // trailing: isLoading ? const CircularProgressIndicator() : null,
      title: Text(item.title),
      // onTap: () {
      //   _toggleStar(getBloc<GitHubCubit>(context));
      // },
    );
  }
}

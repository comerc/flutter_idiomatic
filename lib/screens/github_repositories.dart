import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_idiomatic/import.dart';

class GitHubRepositoriesScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/github',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          GitHubRepositoriesCubit(getRepository<GitHubRepository>(context)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('GitHub Repositories'),
          actions: [
            _ActionButton(
              title: 'Undo'.toUpperCase(),
              buildOnPressed: (GitHubRepositoriesCubit cubit) =>
                  cubit.canUndo ? cubit.undo : null,
            ),
            _ActionButton(
              title: 'Reset'.toUpperCase(),
              buildOnPressed: (GitHubRepositoriesCubit cubit) => cubit.reset,
            ),
            _ActionButton(
              title: 'Redo'.toUpperCase(),
              buildOnPressed: (GitHubRepositoriesCubit cubit) =>
                  cubit.canRedo ? cubit.redo : null,
            ),
          ],
        ),
        body: GitHubRepositoriesBody(),
      ),
    );
  }
}

class GitHubRepositoriesBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GitHubRepositoriesCubit, GitHubRepositoriesState>(
      builder: (BuildContext context, GitHubRepositoriesState state) {
        if (state.status == GitHubStatus.initial && state.items.isEmpty) {
          return Center(
              child: FloatingActionButton(
            onPressed: () {
              load(() => getBloc<GitHubRepositoriesCubit>(context).load());
            },
            child: Icon(Icons.replay),
          ));
        }
        if (state.status == GitHubStatus.busy && state.items.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: state.items.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == state.items.length) {
                    if (state.status == GitHubStatus.busy) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (state.status == GitHubStatus.ready) {
                      return Center(
                        child: FlatButton(
                          shape: StadiumBorder(),
                          onPressed: () {
                            load(() => getBloc<GitHubRepositoriesCubit>(context)
                                .load());
                          },
                          child: Text(
                            'Refresh'.toUpperCase(),
                            style: TextStyle(color: theme.primaryColor),
                          ),
                        ),
                      );
                    }
                    return Container();
                  }
                  final item = state.items[index];
                  return _Item(
                    key: Key(item.id),
                    item: item,
                    isLoading: state.loadingItems.contains(item.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Item extends StatelessWidget {
  _Item({
    Key key,
    this.item,
    this.isLoading,
  }) : super(key: key);

  final RepositoryModel item;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      preferBelow: false,
      message: 'Toggle Star',
      child: ListTile(
        leading: item.viewerHasStarred
            ? Icon(
                Icons.star,
                color: Colors.amber,
              )
            : Icon(Icons.star_border),
        trailing: isLoading ? CircularProgressIndicator() : null,
        title: Text(item.name),
        onTap: () {
          _toggleStar(getBloc<GitHubRepositoriesCubit>(context));
        },
      ),
    );
  }

  Future<void> _toggleStar(GitHubRepositoriesCubit cubit) async {
    final value = !item.viewerHasStarred;
    try {
      await cubit.toggleStar(
        id: item.id,
        value: value,
      );
    } on Exception {
      BotToast.showNotification(
        title: (_) => Text(
          value
              ? 'Can not starred "${item.name}"'
              : 'Can not unstarred "${item.name}"',
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        trailing: (Function close) => FlatButton(
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            close();
            _toggleStar(cubit);
          },
          child: Text('Repeat'.toUpperCase()),
        ),
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    Key key,
    this.title,
    this.buildOnPressed,
  }) : super(key: key);

  final String title;
  final VoidCallback Function(GitHubRepositoriesCubit cubit) buildOnPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GitHubRepositoriesCubit, GitHubRepositoriesState>(
      builder: (BuildContext context, GitHubRepositoriesState state) {
        final cubit = getBloc<GitHubRepositoriesCubit>(context);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            elevation: 0,
            onPressed: buildOnPressed(cubit),
            child: Text(
              title,
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        );
      },
    );
  }
}

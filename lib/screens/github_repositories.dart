import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/import.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('GitHub Repositories')),
      body: BlocProvider(
        create: (BuildContext context) {
          final cubit =
              GitHubRepositoriesCubit(getRepository<GitHubRepository>(context));
          _loadRepositories(cubit);
          return cubit;
        },
        child: GitHubRepositoriesBody(),
      ),
    );
  }

  static Future<void> _loadRepositories(GitHubRepositoriesCubit cubit) async {
    final result = await cubit.load();
    if (result) return;
    BotToast.showNotification(
      title: (_) => const Text(
        'Can not load repositories',
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      trailing: (Function close) => FlatButton(
        onLongPress: () {}, // чтобы сократить время для splashColor
        onPressed: () {
          close();
          _loadRepositories(cubit);
        },
        child: Text('Repeat'.toUpperCase()),
      ),
    );
  }
}

class GitHubRepositoriesBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GitHubRepositoriesCubit, GitHubRepositoriesState>(
      builder: (BuildContext context, GitHubRepositoriesState state) {
        if (state.status == GitHubStatus.busy && state.items.isEmpty) {
          return Center(child: const CircularProgressIndicator());
        }
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: state.items.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == state.items.length) {
                    if (state.status == GitHubStatus.busy) {
                      return Center(child: const CircularProgressIndicator());
                    }
                    if (state.status == GitHubStatus.ready) {
                      return Center(
                        child: FlatButton(
                            child: Text(
                              'Refresh'.toUpperCase(),
                              style: TextStyle(color: theme.primaryColor),
                            ),
                            shape: const StadiumBorder(),
                            onPressed: () {
                              GitHubRepositoriesScreen._loadRepositories(
                                getBloc<GitHubRepositoriesCubit>(context),
                              );
                            }),
                      );
                    }
                    return Container();
                  }
                  final item = state.items[index];
                  return GitHubRepositoriesItem(
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

class GitHubRepositoriesItem extends StatelessWidget {
  const GitHubRepositoriesItem({
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
            ? const Icon(
                Icons.star,
                color: Colors.amber,
              )
            : const Icon(Icons.star_border),
        trailing: isLoading ? const CircularProgressIndicator() : null,
        title: Text(item.name),
        onTap: () {
          _toggleStar(getBloc<GitHubRepositoriesCubit>(context));
        },
      ),
    );
  }

  Future<void> _toggleStar(GitHubRepositoriesCubit cubit) async {
    final value = !item.viewerHasStarred;
    final result = await cubit.toggleStar(
      id: item.id,
      value: value,
    );
    if (result) return;
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

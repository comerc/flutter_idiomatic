import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/import.dart';

class GitHubScreen extends StatelessWidget {
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
      appBar: AppBar(title: const Text('GitHub')),
      body: BlocProvider(
        create: (BuildContext context) {
          final cubit = GitHubCubit(getRepository<GitHubRepository>(context));
          _loadRepositories(cubit);
          return cubit;
        },
        child: GitHubBody(),
      ),
    );
  }
}

void _loadRepositories(GitHubCubit cubit) async {
  final result = await cubit.loadRepositories();
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
      child: const Text('REPEAT'),
    ),
  );
}

class GitHubBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GitHubCubit, GitHubState>(
      builder: (BuildContext context, GitHubState state) {
        if (state.status == GitHubStatus.busy && state.repositories.isEmpty) {
          return Center(child: const CircularProgressIndicator());
        }
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: state.repositories.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == state.repositories.length) {
                    if (state.status == GitHubStatus.busy) {
                      return Center(child: const CircularProgressIndicator());
                    }
                    if (state.status == GitHubStatus.ready) {
                      return Center(
                        child: FlatButton(
                            child: Text(
                              'REFRESH',
                              style: TextStyle(color: theme.primaryColor),
                            ),
                            shape: StadiumBorder(),
                            onPressed: () {
                              _loadRepositories(getBloc<GitHubCubit>(context));
                            }),
                      );
                    }
                    return Container();
                  }
                  final item = state.repositories[index];
                  return GitHubItem(
                    key: Key(item.id),
                    repository: item,
                    isLoading: state.loadingRepositories.contains(item.id),
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

class GitHubItem extends StatelessWidget {
  const GitHubItem({
    Key key,
    this.repository,
    this.isLoading,
  }) : super(key: key);

  final RepositoryModel repository;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      preferBelow: false,
      message: 'Toggle Star',
      child: ListTile(
        leading: repository.viewerHasStarred
            ? const Icon(
                Icons.star,
                color: Colors.amber,
              )
            : const Icon(Icons.star_border),
        trailing: isLoading ? const CircularProgressIndicator() : null,
        title: Text(repository.name),
        onTap: () {
          _toggleStar(getBloc<GitHubCubit>(context));
        },
      ),
    );
  }

  void _toggleStar(GitHubCubit cubit) async {
    final value = !repository.viewerHasStarred;
    final result = await cubit.toggleStar(
      id: repository.id,
      value: value,
    );
    if (result) return;
    BotToast.showNotification(
      title: (_) => Text(
        value
            ? 'Can not starred "${repository.name}"'
            : 'Can not unstarred "${repository.name}"',
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      trailing: (Function close) => FlatButton(
        onLongPress: () {}, // чтобы сократить время для splashColor
        onPressed: () {
          close();
          _toggleStar(cubit);
        },
        child: const Text('REPEAT'),
      ),
    );
  }
}

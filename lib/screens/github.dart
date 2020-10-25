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
        create: (BuildContext context) =>
            GitHubCubit(getRepository<GitHubRepository>(context))..load(),
        child: GitHubBody(),
      ),
    );
  }
}

class GitHubBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GitHubCubit, GitHubState>(
      listener: (BuildContext context, GitHubState state) {
        if (state is GitHubLoadFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('GitHub Load Failure')),
            );
        }
      },
      builder: (BuildContext context, GitHubState state) {
        if (state is GitHubLoadInProgress) {
          return Center(child: const CircularProgressIndicator());
        }
        if (state is GitHubLoadSuccess && state.repositories.isNotEmpty) {
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: state.repositories.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = state.repositories[index];
                    return BlocProvider(
                      create: (context) => GitHubItemCubit(
                        getRepository<GitHubRepository>(context),
                        item: item,
                      ),
                      child: GitHubItem(key: Key(item.id)),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return Center(
          child: Text('none'),
        );
      },
    );
  }
}

class GitHubItem extends StatelessWidget {
  const GitHubItem({
    Key key,
  }) : super(key: key);

  // Map<String, Object> extractRepositoryData(Object data) {
  //   final action =
  //       (data as Map<String, Object>)['action'] as Map<String, Object>;
  //   if (action == null) {
  //     return null;
  //   }
  //   return action['starrable'] as Map<String, Object>;
  // }

  // bool get starred => repository['viewerHasStarred'] as bool;
  // bool get optimistic => (repository as LazyCacheMap).isOptimistic;

  // Map<String, dynamic> get expectedResult => <String, dynamic>{
  //       'action': <String, dynamic>{
  //         'starrable': <String, dynamic>{'viewerHasStarred': !starred}
  //       }
  //     };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GitHubItemCubit, GitHubItemState>(
      builder: (BuildContext context, GitHubItemState state) {
        final repository = state.item;
        return ListTile(
          leading: repository.viewerHasStarred
              ? const Icon(
                  Icons.star,
                  color: Colors.amber,
                )
              : const Icon(Icons.star_border),
          trailing: state.status == GitHubItemStatus.loading
              ? const CircularProgressIndicator()
              : null,
          title: Text(repository.name),
          onTap: () {
            getBloc<GitHubItemCubit>(context).toggleStar(
              id: repository.id,
              value: true,
            );

            // toggleStar(
            //   <String, dynamic>{
            //     'starrableId': repository['id'],
            //   },
            //   optimisticResult: expectedResult,
            // );
          },
        );
      },
    );
  }
}

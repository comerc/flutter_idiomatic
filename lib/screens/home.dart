import 'package:flutter/material.dart';
import 'package:flutter_firebase_login/import.dart';

class HomeScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/home',
      builder: (_) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = getBloc<AuthenticationCubit>(context).state.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: <Widget>[
          IconButton(
            key: const Key('homeScreen_logout_iconButton'),
            icon: const Icon(Icons.exit_to_app),
            onPressed: () =>
                getBloc<AuthenticationCubit>(context).requestLogout(),
          )
        ],
      ),
      body: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Avatar(photo: user.photo),
            const SizedBox(height: 4),
            Text(user.email, style: textTheme.headline6),
            const SizedBox(height: 4),
            Text(user.name ?? '', style: textTheme.headline5),
            const SizedBox(height: 4),
            _CommonRaisedButton(
              title: 'GitHub Repositories',
              buttonKey:
                  const Key('homeScreen_gitHubRepositories_raisedButton'),
              onPressed: () =>
                  navigator.push<void>(GitHubRepositoriesScreen().getRoute()),
            ),
            const SizedBox(height: 4),
            _CommonRaisedButton(
              title: 'Todos',
              buttonKey: const Key('homeScreen_todos_raisedButton'),
              onPressed: () => navigator.push<void>(TodosScreen().getRoute()),
            ),
            const SizedBox(height: 4),
            _CommonRaisedButton(
              title: 'Animated List',
              buttonKey: const Key('homeScreen_animatedList_raisedButton'),
              onPressed: () =>
                  navigator.push<void>(AnimatedListScreen().getRoute()),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommonRaisedButton extends StatelessWidget {
  _CommonRaisedButton({this.title, this.buttonKey, this.onPressed});

  final String title;
  final Key buttonKey;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RaisedButton(
      key: buttonKey,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      shape: const StadiumBorder(),
      color: theme.accentColor,
      onPressed: onPressed,
    );
  }
}

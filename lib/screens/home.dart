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
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            key: Key('homeScreen_logout_iconButton'),
            icon: Icon(Icons.exit_to_app),
            onPressed: () =>
                getBloc<AuthenticationCubit>(context).requestLogout(),
          )
        ],
      ),
      body: Align(
        alignment: Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Avatar(photo: user.photo),
            SizedBox(height: 4),
            Text(user.email, style: textTheme.headline6),
            SizedBox(height: 4),
            Text(user.name ?? '', style: textTheme.headline5),
            SizedBox(height: 4),
            _CommonRaisedButton(
              title: 'GitHub Repositories',
              buttonKey: Key('homeScreen_gitHubRepositories_raisedButton'),
              onPressed: () =>
                  navigator.push<void>(GitHubRepositoriesScreen().getRoute()),
            ),
            SizedBox(height: 4),
            _CommonRaisedButton(
              title: 'Todos',
              buttonKey: Key('homeScreen_todos_raisedButton'),
              onPressed: () => navigator.push<void>(TodosScreen().getRoute()),
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
      shape: StadiumBorder(),
      color: theme.accentColor,
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

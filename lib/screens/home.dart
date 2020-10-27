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
            const SizedBox(height: 4.0),
            Text(user.email, style: textTheme.headline6),
            const SizedBox(height: 4.0),
            Text(user.name ?? '', style: textTheme.headline5),
            const SizedBox(height: 4.0),
            _CommonButton(
              title: 'GitHub',
              buttonKey: 'homeScreen_gitHub_raisedButton',
              route: GitHubScreen().getRoute(),
            ),
            const SizedBox(height: 4.0),
            _CommonButton(
              title: 'My Todos',
              buttonKey: 'homeScreen_myTodosButton_raisedButton',
              route: MyTodosScreen().getRoute(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommonButton extends StatelessWidget {
  _CommonButton({this.title, this.buttonKey, this.route});

  final String title;
  final String buttonKey;
  final Route route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RaisedButton(
      key: Key(buttonKey),
      child: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      shape: StadiumBorder(),
      color: theme.accentColor,
      onPressed: () => navigator.push<void>(route),
    );
  }
}

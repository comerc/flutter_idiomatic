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
        actions: <Widget>[_LogoutBotton()],
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
            _GitHubRepositoriesButton(),
            SizedBox(height: 4),
            _TodosButton(),
          ],
        ),
      ),
    );
  }
}

class _LogoutBotton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: Key('$runtimeType'),
      icon: Icon(Icons.exit_to_app),
      onPressed: () => getBloc<AuthenticationCubit>(context).requestLogout(),
    );
  }
}

class _GitHubRepositoriesButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RaisedButton(
      key: Key('$runtimeType'),
      shape: StadiumBorder(),
      color: theme.accentColor,
      onPressed: () =>
          navigator.push<void>(GitHubRepositoriesScreen().getRoute()),
      child: Text(
        'GitHub Repositories',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class _TodosButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RaisedButton(
      key: Key('$runtimeType'),
      shape: StadiumBorder(),
      color: theme.accentColor,
      onPressed: () => navigator.push<void>(TodosScreen().getRoute()),
      child: Text(
        'Todos',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

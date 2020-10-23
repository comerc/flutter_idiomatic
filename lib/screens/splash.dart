import 'package:flutter/material.dart';
import 'package:flutter_firebase_login/import.dart';

class SplashScreen extends StatelessWidget {
  Route get route {
    return buildRoute<void>(
      '/splash',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/bloc_logo_small.png',
          key: const Key('splash_bloc_image'),
          width: 150,
        ),
      ),
    );
  }
}

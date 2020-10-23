// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_firebase_login/import.dart';

void main() {
  group('SplashScreen', () {
    test('has a route', () {
      expect(SplashScreen().route, isA<Route>());
    });

    testWidgets('renders bloc image', (tester) async {
      await tester.pumpWidget(MaterialApp(home: SplashScreen()));
      expect(find.byKey(const Key('splash_bloc_image')), findsOneWidget);
    });
  });
}

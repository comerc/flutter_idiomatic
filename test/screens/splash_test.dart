import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_idiomatic/import.dart';

void main() {
  group('SplashScreen', () {
    test('has a route', () {
      expect(SplashScreen().getRoute(), isA<Route>());
    });

    testWidgets('renders bloc image', (tester) async {
      await tester.pumpWidget(MaterialApp(home: SplashScreen()));
      expect(find.byKey(Key('_Logo')), findsOneWidget);
    });
  });
}

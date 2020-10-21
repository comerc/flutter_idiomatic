import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart' as test;

void testFlutterBloc<C extends Cubit<State>, R, State>(
  String description, {
  @required R Function() repository,
  @required C Function(BuildContext context) builder,
  Function(C cubit) act,
  Duration wait,
  int skip = 0,
  Iterable expect,
  Function(C cubit) verify,
  Iterable errors,
}) {
  testWidgets(description, (WidgetTester tester) async {
    await tester.pumpWidget(
      RepositoryProvider.value(
        value: repository(),
        child: Builder(
          builder: (BuildContext context) {
            print('1 ${context}');
            tester.runAsync(() async {
              final unhandledErrors = <Object>[];
              await runZonedGuarded(() async {
                final states = <State>[];
                print('2 ${context}');
                final cubit = builder(context);
                final subscription = cubit.skip(skip).listen(states.add);
                await act?.call(cubit);
                if (wait != null) await Future<void>.delayed(wait);
                await Future<void>.delayed(Duration.zero);
                await cubit.close();
                if (expect != null) test.expect(states, expect);
                await subscription.cancel();
                await verify?.call(cubit);
              }, (Object error, StackTrace stackTrace) {
                if (error is CubitUnhandledErrorException) {
                  unhandledErrors.add(error.error);
                } else {
                  // ignore: only_throw_errors
                  throw error;
                }
              });
              if (errors != null) test.expect(unhandledErrors, errors);
            });
            return Container();
          },
        ),
      ),
    );
  });
}

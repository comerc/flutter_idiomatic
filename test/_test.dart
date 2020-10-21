import 'dart:async';

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart' as test;

// import 'test_flutter_bloc.dart';

bool out(String value) {
  debugPrint(value);
  return true;
}

T getRepository<T>(BuildContext context) => RepositoryProvider.of<T>(context);

class Repository {
  bool getTrue() {
    return true;
  }
}

class MockRepository extends Mock implements Repository {
  String getMe() {
    return 'getMe';
  }
}

class MockBuildContext extends Mock implements BuildContext {}

class CounterState extends Equatable {
  CounterState({this.value = 10});

  final int value;

  @override
  List<Object> get props => [value];

  CounterState copyWith({
    int value,
  }) {
    return CounterState(
      value: value ?? this.value,
    );
  }
}

class CounterCubit<T extends Repository> extends Cubit<CounterState> {
  CounterCubit(BuildContext context)
      // : _repo = getRepository<T>(context),
      : assert(out('> ${getRepository<T>(context)}')),
        super(CounterState());

  // final T _repo;
  // final _b;

  /// Add 1 to the current state.
  Future<void> increment() async {
    emit(state.copyWith(value: state.value + 1));
    await Future.delayed(Duration(seconds: 1));
    emit(state.copyWith(value: state.value + 1));
    await Future.delayed(Duration(seconds: 1));
    decrement();
  }
  // void increment() => emit(state + 1);

  /// Subtract 1 from the current state.
  void decrement() => emit(state.copyWith(value: state.value - 1));
  // void decrement() => emit(state - 1);
}

void main() {
  Repository _repository;

  setUp(() {
    // sut = MyClass();
    // _mockContext = MockBuildContext();
    _repository = MockRepository();
  });

  // test('check context', () {
  //   CounterCubit2(_mockContext);
  // });

  // setUp(() {
  //   // repository = MockRepository();
  //   // when(repository.getTrue).thenAnswer(
  //   //   (_) => () => false,
  //   // );
  // });

  // test.test('me testing', () {
  //   // print(_context);

  //   // var actual = sut.myMethodName(_mockContext, '1234');

  //   // expect(actual, '1234');
  // });

  // testWidgets('me testing', (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     Builder(
  //       builder: (BuildContext context) {
  //         var actual = sut.myMethodName(context, '1234');
  //         expect(actual, '1234');

  //         // The builder function must return a widget.
  //         return Placeholder();
  //       },
  //     ),
  //   );
  // });

  // testWidgets('me testing', (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     Builder(
  //       builder: (BuildContext context) {
  //         // expect(0, 0);
  //         // return Placeholder();
  //         return RepositoryProvider.value(
  //           value: MockRepository(),
  //           child: BlocProvider<CounterCubit<MockRepository>>(
  //             create: (BuildContext context) =>
  //                 CounterCubit<MockRepository>(context),
  //             child: BlocBuilder<CounterCubit<MockRepository>, int>(
  //               builder: (BuildContext context, int state) {
  //                 // expect(state, 0);
  //                 print(state);
  //                 print(
  //                     '${BlocProvider.of<CounterCubit<MockRepository>>(context).state}');
  //                 return SizedBox();
  //               },
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  //   expect(find.byType(SizedBox), findsOneWidget);
  // });

  // testWidgets('me testing', (WidgetTester tester) async {
  //   // BuildContext _context;
  //   await tester.pumpWidget(
  //     Builder(
  //       builder: (BuildContext context) {
  //         // expect(0, 0);
  //         // return Placeholder();
  //         return RepositoryProvider.value(
  //           value: MockRepository(),
  //           child: Builder(
  //             builder: (BuildContext context) {
  //               // final counter = CounterCubit<MockRepository>(context);
  //               // counter.increment();
  //               // expect(counter.state, 1);
  //               // blocTest<CounterCubit<MockRepository>, CounterState>(
  //               //   tester,
  //               //   'bla bla bla',
  //               //   build: () => CounterCubit<MockRepository>(context),
  //               //   act: (CounterCubit<MockRepository> cubit) =>
  //               //       cubit.increment(),
  //               //   expect: <CounterState>[
  //               //     CounterState(value: 11),
  //               //     CounterState(value: 12),
  //               //     CounterState(value: 12)
  //               //   ],
  //               // );

  //               return Container();
  //             },
  //           ),
  //         );
  //       },
  //     ),
  //   );
  //   // await tester.runAsync(() => Future.delayed(Duration(seconds: 1)));
  //   // print(_context);
  //   // await Future.delayed(Duration(seconds: 1));
  //   // print('1234');
  //   // await fn();
  //   expect(find.byType(Container), findsOneWidget);
  // });

  testFlutterBloc<CounterCubit, Repository, CounterState>(
    'bla bla bla',
    repository: () => _repository,
    builder: (BuildContext context) => CounterCubit<Repository>(context),
    act: (CounterCubit cubit) => cubit.increment(),
    expect: <CounterState>[
      CounterState(value: 11),
      CounterState(value: 12),
      CounterState(value: 11),
    ],
  );
}

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

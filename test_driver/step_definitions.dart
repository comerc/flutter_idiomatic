import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart' hide step;
import 'step.dart';

// TODO: перевод для pattern https://github.com/jonsamwell/flutter_gherkin/issues/94
// 'я имею {string} ключ и {string} ключ и {string} ключ',

StepDefinitionGeneric check3() {
  return step3<String, String, String, FlutterWorld>(
    'I have {string} and {string} and {string}',
    (String input1, String input2, String input3,
        StepContext<FlutterWorld> context) async {
      context.expect(
          await FlutterDriverUtils.isPresent(
              context.world.driver, getFinder(input1)),
          true);
      context.expect(
          await FlutterDriverUtils.isPresent(
              context.world.driver, getFinder(input2)),
          true);
      context.expect(
          await FlutterDriverUtils.isPresent(
              context.world.driver, getFinder(input3)),
          true);
    },
  );
}

StepDefinitionGeneric tap() {
  return step1<String, FlutterWorld>(
    'I tap the {string}',
    (String input, StepContext<FlutterWorld> context) async {
      await FlutterDriverUtils.tap(context.world.driver, getFinder(input));
      await FlutterDriverUtils.waitForFlutter(context.world.driver);
    },
  );
}

// StepDefinitionGeneric checkByKey() {
//   return step1<String, FlutterWorld>(
//     'I have {string} key',
//     (String key, StepContext<FlutterWorld> context) async {
//       context.expect(
//           await FlutterDriverUtils.isPresent(
//               context.world.driver, find.byValueKey(key)),
//           true);
//     },
//   );
// }

// StepDefinitionGeneric checkByType() {
//   return step1<String, FlutterWorld>(
//     'I have {string} type',
//     (String type, StepContext<FlutterWorld> context) async {
//       context.expect(
//           await FlutterDriverUtils.isPresent(
//               context.world.driver, find.byType(type)),
//           true);
//     },
//   );
// }

StepDefinitionGeneric check() {
  return step1<String, FlutterWorld>(
    'I have {string}',
    (String input, StepContext<FlutterWorld> context) async {
      context.expect(
          await FlutterDriverUtils.isPresent(
              context.world.driver, getFinder(input)),
          true);
    },
  );
}

SerializableFinder getFinder(String input) {
  final finder = input.startsWith('_') ? find.byValueKey : find.byType;
  return finder(input);
}

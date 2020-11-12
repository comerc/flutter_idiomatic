import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart' hide step;
import 'step.dart';

// TODO: перевод для pattern https://github.com/jonsamwell/flutter_gherkin/issues/94
// 'я имею {string} ключ и {string} ключ и {string} ключ',

StepDefinitionGeneric check3ByKeys() {
  return step3<String, String, String, FlutterWorld>(
    'I have {string} key and {string} key and {string} key',
    (String key1, String key2, String key3,
        StepContext<FlutterWorld> context) async {
      context.expect(
          await FlutterDriverUtils.isPresent(
              context.world.driver, find.byValueKey(key1)),
          true);
      context.expect(
          await FlutterDriverUtils.isPresent(
              context.world.driver, find.byValueKey(key2)),
          true);
      context.expect(
          await FlutterDriverUtils.isPresent(
              context.world.driver, find.byValueKey(key3)),
          true);
    },
  );
}

StepDefinitionGeneric tapByKey() {
  return step1<String, FlutterWorld>(
    'I tap the {string} key',
    (String key, StepContext<FlutterWorld> context) async {
      await FlutterDriverUtils.tap(context.world.driver, find.byValueKey(key));
      await FlutterDriverUtils.waitForFlutter(context.world.driver);
    },
  );
}

StepDefinitionGeneric checkByKey() {
  return step1<String, FlutterWorld>(
    'I have {string} key',
    (String key, StepContext<FlutterWorld> context) async {
      context.expect(
          await FlutterDriverUtils.isPresent(
              context.world.driver, find.byValueKey(key)),
          true);
    },
  );
}

StepDefinitionGeneric checkByType() {
  return step1<String, FlutterWorld>(
    'I have {string} type',
    (String type, StepContext<FlutterWorld> context) async {
      context.expect(
          await FlutterDriverUtils.isPresent(
              context.world.driver, find.byType(type)),
          true);
    },
  );
}

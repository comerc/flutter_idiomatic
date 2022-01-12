import 'dart:async';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:glob/glob.dart';
// import 'hook_example.dart';
import 'step_definitions.dart';

Future<void> main() {
  final config = FlutterTestConfiguration()
    ..features = [Glob(r"test_driver/features/**.feature")]
    ..reporters = [
      ProgressReporter(),
      TestRunSummaryReporter(),
      // JsonReporter(path: './report/report.json')
    ] // you can include the "StdoutReporter()" without the message level parameter for verbose log information
    ..hooks = [
      // HookExample()
    ] // you can include "AttachScreenhotOnFailedStepHook()" to take a screenshot of each step failure and attach it to the world object
    ..stepDefinitions = [
      check3(),
      tap(),
      check(),
    ]
    // ..customStepParameterDefinitions = [ColourParameter()]
    ..restartAppBetweenScenarios = true
    // ..buildFlavor = "staging" // uncomment when using build flavor and check android/ios flavor setup see android file android\app\build.gradle
    // ..targetDeviceId = "all" // uncomment to run tests on all connected devices or set specific device target id
    ..targetDeviceId = "emulator-5554" // $ flutter devices
    // ..tagExpression = "@smoke" // uncomment to see an example of running scenarios based on tag expressions
    // ..exitAfterTestRun = true // set to false if debugging to exit cleanly
    ..targetAppPath = "test_driver/app.dart";
  return GherkinRunner().execute(config);
}

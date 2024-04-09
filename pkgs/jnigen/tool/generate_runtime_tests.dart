// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart';
import 'package:args/args.dart';

import 'package:jnigen/src/logging/logging.dart';

final lineBreak = Platform.isWindows ? '\r\n' : '\n';

void runCommand(String exec, List<String> args) {
  final proc = Process.runSync(exec, args, runInShell: true);
  log.info('Execute $exec ${args.join(" ")}');
  if (proc.exitCode != 0) {
    exitCode = proc.exitCode;
    printError(proc.stdout);
    printError(proc.stderr);
    throw Exception('Command failed: $exec ${args.join(" ")}');
  }
}

const testPath = 'test';
const registrantFileName = 'runtime_test_registrant.dart';
const dartOnlyRegistrantFileName =
    'runtime_test_registrant_dartonly_generated.dart';

// Paths of generated files, should not be checked in.
// If you change this, add the corresponding entry to .gitignore as well.
const replicaSuffix = '_dartonly_generated.dart';
final runnerFilePath = join(testPath, 'generated_runtime_test.dart');
final androidRunnerFilePath =
    join('android_test_runner', 'integration_test', 'runtime_test.dart');

final generatedComment =
    '// Generated file. Do not edit or check-in to version control.$lineBreak';
const copyright = '''
// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''';

const bindingTests = [
  'jackson_core_test',
  'simple_package_test',
  'kotlin_test',
];

const hasThirdPartyDir = {'jackson_core_test'};

final _generatedFiles = <String>[
  for (var testName in bindingTests)
    join(testPath, testName, dartOnlyRegistrantFileName),
  runnerFilePath,
  androidRunnerFilePath,
];

void generateReplicasAndRunner() {
  final imports = <String, String>{};
  for (var testName in bindingTests) {
    final registrant = join(testName, registrantFileName);
    final registrantFile = File(join(testPath, registrant));
    final contents = registrantFile
        .readAsStringSync()
        .replaceAll('c_based/dart_bindings/', 'dart_only/dart_bindings/');

    final replica = registrant.replaceAll('.dart', replicaSuffix);
    final replicaFile = File(join(testPath, replica));
    replicaFile.writeAsStringSync('$generatedComment$lineBreak$contents');
    log.info('Generated $replica');
    imports['${testName}_c_based'] =
        Uri.file(registrant).toFilePath(windows: false);
    imports['${testName}_dart_only'] =
        Uri.file(replica).toFilePath(windows: false);
  }
  final importStrings = imports.entries
      .map((e) => 'import "${e.value}" as ${e.key};')
      .join(lineBreak);
  final androidImportStrings = imports.entries
      .map((e) => 'import "../../test/${e.value}" as ${e.key};')
      .join(lineBreak);
  final runStrings = imports.keys
      .map((name) => '$name.registerTests("$name", test);')
      .join('$lineBreak  ');
  final runnerProgram = '''
$generatedComment
$copyright
import 'package:test/test.dart';
import 'test_util/bindings_test_setup.dart' as setup;

$importStrings

void main() {
  setUpAll(setup.bindingsTestSetup);
  $runStrings
  tearDownAll(setup.bindingsTestTeardown);
}
''';
  final runnerFile = File(runnerFilePath);
  runnerFile.writeAsStringSync(runnerProgram);
  log.info('Generated runner $runnerFilePath');

  final androidRunnerProgram = '''
$generatedComment
$copyright
import "package:flutter_test/flutter_test.dart";
import "package:jni/jni.dart";

$androidImportStrings

typedef TestCaseCallback = void Function();

void test(String description, TestCaseCallback testCase) {
  testWidgets(description, (widgetTester) async => testCase());
}

void main() {
  $runStrings
}
''';
  File(androidRunnerFilePath).writeAsStringSync(androidRunnerProgram);
  log.info('Generated android runner: $androidRunnerFilePath');

  final cMakePath =
      join('android_test_runner', 'android', 'app', 'CMakeLists.txt');

  final cmakeSubdirs = bindingTests.map((testName) {
    final indirect = hasThirdPartyDir.contains(testName) ? '/third_party' : '';
    return 'add_subdirectory'
        '(../../../test/$testName$indirect/c_based/c_bindings '
        '${testName}_build)';
  }).join(lineBreak);
  final cMakeConfig = '''
## Parent CMake for Android native build target. This will build
## all C bindings from tests.

cmake_minimum_required(VERSION 3.10)

project(simple_package VERSION 0.0.1 LANGUAGES C)

$cmakeSubdirs
''';
  File(cMakePath).writeAsStringSync(cMakeConfig);
  log.info('Wrote Android CMake file: $cMakePath');
}

void cleanup() {
  for (var path in _generatedFiles) {
    File(path).deleteSync();
    log.info('Deleted $path');
  }
}

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'show help',
      negatable: false,
    )
    ..addFlag(
      'clean',
      abbr: 'c',
      help: 'clear generated files',
      negatable: false,
    );
  final argResults = parser.parse(args);
  if (argResults['help']) {
    stderr.writeln(
        'Generates runtime tests for both Dart-only and C based bindings.');
    stderr.writeln(parser.usage);
    return;
  } else if (argResults['clean']) {
    cleanup();
  } else {
    generateReplicasAndRunner();
    runCommand('dart', ['format', ..._generatedFiles]);
  }
}

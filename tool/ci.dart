// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:ffi';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

void main(List<String> arguments) async {
  final parser = makeArgParser();

  final ArgResults argResults = parser.parse(arguments);

  if (argResults['all'] as bool && argResults['none'] as bool) {
    print('Error: --all and --none are mutually exclusive.');
    exit(1);
  }

  final packages = loadPackagesFromPubspec();

  if (argResults['help'] as bool) {
    print('A command-line tool for running CI checks on the CI or locally.');
    print('');
    print('Applies to the following packages:');
    for (final package in packages) {
      print('  - $package');
    }
    print('');
    print('Usage:');
    print(parser.usage);
    return;
  }

  for (final task in tasks) {
    if (task.shouldRun(argResults)) {
      await task.run(packages: packages, argResults: argResults);
    }
  }
}

ArgParser makeArgParser() {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Prints this help message.',
    )
    ..addFlag(
      'all',
      negatable: false,
      help: 'Enable all tasks. Overridden by --no-<task> flags.',
    )
    ..addFlag(
      'none',
      negatable: false,
      help: 'Disable all tasks. Overridden by --<task> flags.',
    );
  for (final task in tasks) {
    parser.addFlag(
      task.name,
      help: '${task.helpMessage} (defaults to ${task.defaultValue})',
    );
  }
  return parser;
}

/// Represents a single CI task that can be run.
///
/// Each task is a concrete subclass of [Task], providing metadata about the
/// task's name, its default state, and the help message for its corresponding
/// command-line flag.
///
/// The main execution loop iterates through a list of [Task] instances. For each
/// instance, it uses [shouldRun] to determine if the task should be executed
/// based on the command-line flags, and if so, calls the [run] method.
abstract class Task {
  /// The name of the task, used for the command-line flag.
  ///
  /// For example, a name of 'analyze' corresponds to the `--[no-]analyze` flag.
  final String name;

  /// The default state of the task if no master flag (`--all` or `--none`) is
  /// provided.
  final bool defaultValue;

  /// The base help message for the task's command-line flag.
  ///
  /// The `(defaults to ...)` text is added automatically.
  final String helpMessage;

  const Task({
    required this.name,
    required this.defaultValue,
    required this.helpMessage,
  });

  bool shouldRun(ArgResults argResults) {
    final useNone = argResults['none'] as bool;
    final useAll = argResults['all'] as bool;

    if (argResults.wasParsed(name)) {
      return argResults[name] as bool;
    }
    if (useNone) {
      return false;
    }
    if (useAll) {
      return true;
    }
    return defaultValue;
  }

  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  });
}

/// Fetches dependencies using `dart pub get`.
///
/// This is a prerequisite for most other tasks.
class PubTask extends Task {
  const PubTask()
    : super(
        name: 'pub',
        defaultValue: false,
        helpMessage:
            'Run `dart pub get` on the root and non-workspace packages.\n'
            'Run `dart pub global activate coverage`.',
      );

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    const paths = [
      '.',
      'pkgs/hooks_runner/test_data/native_add_version_skew/',
      'pkgs/hooks_runner/test_data/native_add_version_skew_2/',
    ];
    for (final path in paths) {
      await _runProcess('dart', ['pub', 'get', '--directory', path]);
    }
  }
}

/// Runs `dart analyze` to find static analysis issues.
class AnalyzeTask extends Task {
  const AnalyzeTask()
    : super(
        name: 'analyze',
        defaultValue: true,
        helpMessage: 'Run `dart analyze` on the packages.',
      );

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    await _runProcess('dart', ['analyze', '--fatal-infos', ...packages]);
  }
}

/// Checks for code formatting issues with `dart format`.
class FormatTask extends Task {
  const FormatTask()
    : super(
        name: 'format',
        defaultValue: true,
        helpMessage: 'Run `dart format` on the packages.',
      );

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    await _runProcess('dart', [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      ...packages,
    ]);
  }
}

/// Runs various code generation scripts.
///
/// This is used to keep generated files in sync with their sources.
class GenerateTask extends Task {
  const GenerateTask()
    : super(
        name: 'generate',
        defaultValue: true,
        helpMessage: 'Run code generation scripts.',
      );

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    const generators = [
      'pkgs/hooks_runner/test_data/manifest_generator.dart',
      'pkgs/hooks/tool/generate_schemas.dart',
      'pkgs/hooks/tool/generate_syntax.dart',
      'pkgs/hooks/tool/normalize.dart',
      'pkgs/pub_formats/tool/generate.dart',
    ];
    for (final generator in generators) {
      await _runProcess('dart', [generator, '--set-exit-if-changed']);
    }
  }
}

/// Runs the main test suite for all packages.
class TestTask extends Task {
  const TestTask()
    : super(
        name: 'test',
        defaultValue: true,
        helpMessage: 'Run `dart test` on the packages.',
      );

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    final testUris = getTestUris(packages);
    await _runProcess('dart', [
      'test',
      if (Platform.environment['GITHUB_ACTIONS'] != null) '--reporter=github',
      ...testUris,
    ]);
  }
}

/// Runs tests and executables for all examples.
///
/// Ensures that the examples are working and up-to-date.
class ExampleTask extends Task {
  const ExampleTask()
    : super(
        name: 'example',
        defaultValue: true,
        helpMessage: 'Run tests and executables for examples.',
      );

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    const examplesWithTest = [
      'native_dynamic_linking',
      'native_add_app',
      'use_dart_api',
      'download_asset',
      'system_library',
    ];
    for (final exampleWithTest in examplesWithTest) {
      await _runProcess(
        workingDirectory: repositoryRoot.resolve(
          'pkgs/hooks/example/build/$exampleWithTest/',
        ),
        'dart',
        ['test'],
      );
    }

    await _runProcess(
      workingDirectory: repositoryRoot.resolve(
        'pkgs/hooks/example/build/native_add_app/',
      ),
      'dart',
      ['run'],
    );
    await _runProcess(
      workingDirectory: repositoryRoot.resolve(
        'pkgs/hooks/example/build/native_add_app/',
      ),
      'dart',
      ['build', 'cli', 'bin/native_add_app.dart'],
    );
    await _runProcess(
      repositoryRoot
          .resolve(
            'pkgs/hooks/example/build/native_add_app/build/cli/${Abi.current()}/bundle/bin/native_add_app${Platform.isWindows ? '.exe' : ''}',
          )
          .toFilePath(),
      [],
    );
  }
}

/// Generates test coverage reports.
///
/// Depends on `pub` being run to activate the `coverage` package.
class CoverageTask extends Task {
  const CoverageTask()
    : super(
        name: 'coverage',
        defaultValue: false,
        helpMessage:
            'Run `dart run coverage:test_with_coverage` on the packages.',
      );

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    final testUris = getTestUris(packages);
    final scopeOutputs = [
      for (final testUri in testUris) Uri.directory(testUri).pathSegments[1],
    ];
    if (pubTask.shouldRun(argResults)) {
      await _runProcess('dart', ['pub', 'global', 'activate', 'coverage']);
    }
    await _runProcess('dart', [
      'pub',
      'global',
      'run',
      'coverage:test_with_coverage',
      for (final scopeOutput in scopeOutputs) ...[
        '--scope-output',
        scopeOutput,
      ],
      ...testUris,
    ]);
  }
}

const pubTask = PubTask();
const analyzeTask = AnalyzeTask();
const formatTask = FormatTask();
const generateTask = GenerateTask();
const testTask = TestTask();
const exampleTask = ExampleTask();
const coverageTask = CoverageTask();

// The order of tasks is intentional.
final tasks = [
  pubTask,
  analyzeTask,
  formatTask,
  generateTask,
  testTask,
  exampleTask,
  coverageTask,
];

final Uri repositoryRoot = Platform.script.resolve('../');

/// Load the root packages from the workspace. Omit nested test/example packages.
List<String> loadPackagesFromPubspec() {
  final pubspecYaml = loadYaml(
    File.fromUri(repositoryRoot.resolve('pubspec.yaml')).readAsStringSync(),
  );
  final workspace = (pubspecYaml['workspace'] as List).cast<String>();
  final packages = workspace
      .where(
        (package) =>
            !package.contains('test_data') && !package.contains('example'),
      )
      .toList();
  return packages;
}

List<String> getTestUris(List<String> packages) {
  final testUris = <String>[];
  for (final package in packages) {
    final packageTestDirectory = Directory.fromUri(
      repositoryRoot.resolve(package /*might end without slash*/),
    ).uri.resolve('test/');
    if (Directory.fromUri(packageTestDirectory).existsSync()) {
      final relativePath = packageTestDirectory.toFilePath().replaceAll(
        repositoryRoot.toFilePath(),
        '',
      );
      testUris.add(relativePath);
    }
  }
  return testUris;
}

Future<void> _runProcess(
  String executable,
  List<String> arguments, {
  Uri? workingDirectory,
}) async {
  var commandString = '$executable ${arguments.join(' ')}';
  if (workingDirectory != null) {
    commandString = 'cd ${workingDirectory.toFilePath()} && $commandString';
  }
  print('+$commandString');
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory?.toFilePath(),
  );
  final stdoutSub = process.stdout.listen((List<int> data) {
    final decoded = systemEncoding.decode(data);
    stdout.write(decoded);
  });
  final stderrSub = process.stderr.listen((List<int> data) {
    final decoded = systemEncoding.decode(data);
    stderr.write(decoded);
  });

  final (exitCode, _, _) = await (
    process.exitCode,
    stdoutSub.asFuture<void>(),
    stderrSub.asFuture<void>(),
  ).wait;

  if (exitCode != 0) {
    print('+$commandString failed with exitCode ${exitCode}.');
    exit(exitCode);
  }
}

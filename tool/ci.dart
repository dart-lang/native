// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

void main(List<String> arguments) async {
  final parser = makeArgParser();

  final argResults = parser.parse(arguments);

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

  final tasksToRun = tasks.where((task) => task.shouldRun(argResults)).toList();
  if (tasksToRun.isEmpty) {
    print('No tasks specified. Please specify at least one task to run.');
    exit(1);
  }

  for (final task in tasksToRun) {
    await task.run(packages: packages, argResults: argResults);
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
      'fast',
      negatable: false,
      help: 'Skip slow integration tests and apitool.',
    )
    ..addFlag(
      'fix',
      negatable: false,
      help: 'Apply auto-fixes (e.g., dart fix, dart format) instead of just '
          'checking.',
    );
  for (final task in tasks) {
    parser.addFlag(task.name, help: task.helpMessage);
  }
  return parser;
}

/// Represents a single CI task that can be run.
///
/// Each task is a concrete subclass of [Task], providing metadata about the
/// task's name, its default state, and the help message for its corresponding
/// command-line flag.
///
/// The main execution loop iterates through a list of [Task] instances. For
/// each instance, it uses [shouldRun] to determine if the task should be
/// executed based on the command-line flags, and if so, calls the [run] method.
abstract class Task {
  /// The name of the task, used for the command-line flag.
  ///
  /// For example, a name of 'analyze' corresponds to the `--[no-]analyze` flag.
  final String name;

  /// The base help message for the task's command-line flag.
  final String helpMessage;

  const Task({required this.name, required this.helpMessage});

  bool shouldRun(ArgResults argResults) {
    final useAll = argResults['all'] as bool;

    if (argResults.wasParsed(name)) {
      return argResults[name] as bool;
    }
    if (useAll) {
      return true;
    }
    return false;
  }

  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  });
}

/// Ensures all packages are included in the pub workspace or a reason is
/// provided why they cannot be part of the workspace.
class WorkspaceTask extends Task {
  const WorkspaceTask()
      : super(
          name: 'workspace',
          helpMessage:
              'Check that all packages are included in the pub workspace.',
        );

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    final packagesInRepository = _packagesInRepository();
    final packagesInWorkspacePubspec = _packagesInWorkspacePubspec();

    final error = <String>[];

    if (packagesInWorkspacePubspec.missingReason.isNotEmpty) {
      error
        ..add('The following packages are commented out in the workspace '
            'pubspec, but no reason is given why they cannot be part of the '
            'workspace:')
        ..addAll(packagesInWorkspacePubspec.missingReason
            .map((package) => ' - $package'))
        ..add('Please add a trailing comment to their entry providing a reason '
            'for their exclusion from the workspace.')
        ..add('');
    }

    final notInRepository =
        packagesInWorkspacePubspec.packages.difference(packagesInRepository);
    if (notInRepository.isNotEmpty) {
      error
        ..add('The following packages are listed in the workspace pubspec, but '
            'do not exist in the repository:')
        ..addAll(notInRepository.map((package) => ' - $package'))
        ..add('Please remove them from the workspace pubspec.')
        ..add('');
    }

    final notInWorkspacePubspec =
        packagesInRepository.difference(packagesInWorkspacePubspec.packages);
    if (notInWorkspacePubspec.isNotEmpty) {
      error
        ..add(
            'The following packages exist in the repository, but are not part '
            'of the workspace:')
        ..addAll(notInWorkspacePubspec.map((package) => ' - $package'))
        ..add(
            'Please add them to the workspace. If that is not possible, add a '
            'commented out entry to the root pubspec and provide a reason why '
            'they cannot be part of the workspace as a trailing comment.')
        ..add('');
    }
    if (error.isNotEmpty) {
      print(error.join('\n'));
      exit(1);
    }
  }

  Set<String> _packagesInRepository() {
    final packages = <String>{};
    final rootDir = Directory.fromUri(repositoryRoot.resolve('pkgs'));
    for (final entity in rootDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('pubspec.yaml')) {
        packages.add(
            Uri.file(p.relative(entity.parent.path, from: repositoryRoot.path))
                .toString());
      }
    }
    return packages;
  }

  ({Set<String> packages, List<String> missingReason})
      _packagesInWorkspacePubspec() {
    final pubspecLines = File.fromUri(repositoryRoot.resolve('pubspec.yaml'))
        .readAsStringSync()
        .split('\n');
    final workspaceEntries = pubspecLines
        .skipWhile((line) => !line.trim().startsWith('workspace:'))
        .skip(1)
        .takeWhile((line) =>
            line.trim().startsWith('- ') || line.trim().startsWith('# - '));

    final packages = <String>{};
    final packagesWithMissingReason = <String>[];

    // Regex breakdown:
    // ^\s*       : Start of line and any leading whitespace
    // (#\s*)?    : Optional leading '#' followed by optional whitespace (Group 1)
    // -\s+       : The YAML list dash '-' and at least one space
    // ([^\s#]+)  : The actual path - any characters that aren't space or '#' (Group 2)
    // (\s*#.*)?  : Optional trailing '#' and everything after it (Group 3)
    final regex = RegExp(r'^\s*(#\s*)?-\s+([^\s#]+)(\s*#.*)?');

    for (final entry in workspaceEntries) {
      final match = regex.firstMatch(entry);

      if (match != null) {
        final hasLeadingHash = match.group(1) != null;
        final path = match.group(2);
        final trailingComment = match.group(3);

        if (hasLeadingHash) {
          if (trailingComment == null || trailingComment.trim().length < 6) {
            packagesWithMissingReason.add(path!);
          }
        }
        packages.add(path!);
      }
    }
    return (packages: packages, missingReason: packagesWithMissingReason);
  }
}

/// Fetches dependencies using `dart pub get`.
///
/// This is a prerequisite for most other tasks.
class PubTask extends Task {
  const PubTask()
      : super(
          name: 'pub',
          helpMessage:
              'Run `dart pub get` on the root and non-workspace packages.\n'
              'Run `dart pub global activate coverage` and `dart_apitool`.',
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
    await _runMaybeParallel([
      for (final path in paths)
        () => _runProcess('dart', ['pub', 'get', '--directory', path]),
    ], argResults);
  }
}

/// Packages that have slow tests.
///
/// https://github.com/dart-lang/native/issues/90#issuecomment-3879193057
const slowTestPackages = [
  'pkgs/hooks_runner',
  'pkgs/native_toolchain_c',
];

/// Runs `dart analyze` to find static analysis issues.
class AnalyzeTask extends Task {
  const AnalyzeTask()
      : super(
          name: 'analyze',
          helpMessage: 'Run `dart analyze` on the packages.',
        );

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    if (argResults['fix'] as bool) {
      await _runMaybeParallel([
        for (final path in [...packages, 'tool'])
          () => _runProcess('dart', ['fix', '--apply', path]),
      ], argResults);
    }
    await _runProcess('dart', [
      'analyze',
      '--fatal-infos',
      ...packages,
      'tool',
    ]);
  }
}

/// Checks for code formatting issues with `dart format`.
class FormatTask extends Task {
  const FormatTask()
      : super(
          name: 'format',
          helpMessage: 'Run `dart format` on the packages.',
        );

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    final fix = argResults['fix'] as bool;
    await _runProcess('dart', [
      'format',
      if (!fix) ...['--output=none', '--set-exit-if-changed'],
      ...packages,
      'tool',
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
      'pkgs/hooks/tool/update_snippets.dart',
      'pkgs/pub_formats/tool/generate.dart',
      'pkgs/record_use/tool/generate_syntax.dart',
    ];
    final fix = argResults['fix'] as bool;
    await _runMaybeParallel([
      for (final generator in generators)
        () => _runProcess('dart', [
              generator,
              if (!fix) '--set-exit-if-changed',
            ]),
    ], argResults);
  }
}

/// Runs the main test suite for all packages.
class TestTask extends Task {
  const TestTask()
      : super(
          name: 'test',
          helpMessage: 'Run `dart test` on the packages.\n'
              'Implied by --coverage.',
        );

  @override
  bool shouldRun(ArgResults argResults) {
    return super.shouldRun(argResults) || coverageTask.shouldRun(argResults);
  }

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    if (argResults['fast'] as bool) {
      packages = packages
          .where((p) => !slowTestPackages.any((slow) => p.contains(slow)))
          .toList();
    }
    final testUris = getUriInPackage(packages, 'test');
    await _runProcess('dart', [
      'test',
      if (coverageTask.shouldRun(argResults)) '--coverage=./coverage',
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
          helpMessage: 'Run tests and executables for examples.',
        );

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    const examplesWithTest = [
      'pkgs/code_assets/example/host_name/',
      'pkgs/code_assets/example/mini_audio/',
      'pkgs/code_assets/example/sqlite_prebuilt/',
      'pkgs/code_assets/example/sqlite/',
      'pkgs/code_assets/example/stb_image/',
      'pkgs/hooks/example/build/download_asset/',
      'pkgs/hooks/example/build/native_add_app/',
      'pkgs/hooks/example/build/native_dynamic_linking/',
      'pkgs/hooks/example/build/system_library/',
      'pkgs/hooks/example/build/use_dart_api/',
    ];
    await _runMaybeParallel([
      for (final exampleWithTest in examplesWithTest)
        () => _runProcess(
              workingDirectory: repositoryRoot.resolve(exampleWithTest),
              'dart',
              ['test'],
            ),
    ], argResults);

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
          helpMessage: 'Collect coverage information on the packages.\n'
              'Implies --test.',
        );

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    if (pubTask.shouldRun(argResults)) {
      await _runProcess('dart', ['pub', 'global', 'activate', 'coverage']);
    }
    // Don't rerun the tests here. Instead, rely on the TestTask producing
    // coverage information, and only format here.
    final libUris = getUriInPackage(packages, 'lib');
    await _runProcess('dart', [
      'pub',
      'global',
      'run',
      'coverage:format_coverage',
      '--packages=.dart_tool/package_config.json',
      for (final libUri in libUris) '--report-on=$libUri',
      '--lcov',
      '-o',
      './coverage/lcov.info',
      '-i',
      './coverage/pkgs/',
    ]);
  }
}

/// Checks for leaked symbols in the public API using `dart_apitool`.
class ApiToolTask extends Task {
  const ApiToolTask()
      : super(
          name: 'apitool',
          helpMessage: 'Run `dart_apitool` to check for leaked symbols.',
        );

  @override
  bool shouldRun(ArgResults argResults) {
    if (argResults['fast'] as bool && !argResults.wasParsed(name)) {
      return false;
    }
    return super.shouldRun(argResults);
  }

  @override
  Future<void> run({
    required List<String> packages,
    required ArgResults argResults,
  }) async {
    if (pubTask.shouldRun(argResults)) {
      // Pull in https://github.com/bmw-tech/dart_apitool/pull/252.
      await _runProcess('dart', [
        'pub',
        'global',
        'activate',
        '--source',
        'git',
        'https://github.com/bmw-tech/dart_apitool.git',
        '--git-ref',
        '906fa0f3dca24d81d1c26ee71c884ecbb6234ecf',
      ]);
    }
    await _runMaybeParallel([
      for (final package in packages)
        () async {
          final outputFileName = '${package.replaceAll('/', '_')}_api.json';
          await _runProcess('dart', [
            'pub',
            'global',
            'run',
            'dart_apitool:main',
            'extract',
            '--input',
            package,
            '--set-exit-on-missing-export',
            '--output',
            outputFileName,
          ]);
          // Clean up the temporary file.
          final apiJson = File.fromUri(repositoryRoot.resolve(outputFileName));
          if (apiJson.existsSync()) {
            apiJson.deleteSync();
          }
        },
    ], argResults);
  }
}

const pubTask = PubTask();
const analyzeTask = AnalyzeTask();
const formatTask = FormatTask();
const generateTask = GenerateTask();
const testTask = TestTask();
const exampleTask = ExampleTask();
const coverageTask = CoverageTask();
const apiToolTask = ApiToolTask();
const workspaceTask = WorkspaceTask();

// The order of tasks is intentional.
final tasks = [
  pubTask,
  generateTask,
  analyzeTask,
  formatTask,
  testTask,
  exampleTask,
  coverageTask,
  apiToolTask,
  workspaceTask,
];

final Uri repositoryRoot = Platform.script.resolve('../');

/// Load the root packages from the workspace. Omit nested test/example packages.
List<String> loadPackagesFromPubspec() {
  final pubspecYaml = loadYaml(
    File.fromUri(repositoryRoot.resolve('pubspec.yaml')).readAsStringSync(),
  );
  final workspace = ((pubspecYaml as Map)['workspace'] as List).cast<String>();
  final packages = workspace
      .where(
        (package) =>
            !package.contains('test_data') && !package.contains('example'),
      )
      .toList();
  return packages;
}

List<String> getUriInPackage(List<String> packages, String subdir) {
  final testUris = <String>[];
  for (final package in packages) {
    final packageTestDirectory = Directory.fromUri(
      repositoryRoot.resolve(package /*might end without slash*/),
    ).uri.resolve('$subdir/');
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

Future<void> _runMaybeParallel(
  List<Future<void> Function()> tasks,
  ArgResults argResults,
) async {
  if (argResults['fast'] as bool) {
    await Future.wait(tasks.map((task) => task()));
  } else {
    for (final task in tasks) {
      await task();
    }
  }
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
    // Support stderr and stdout directly to the output. This enables
    // `dart test` and friends to replace the last line. Also those tools can
    // detect properly if they run in an interactive terminal.
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    print('+$commandString failed with exitCode $exitCode.');
    exit(exitCode);
  }
}

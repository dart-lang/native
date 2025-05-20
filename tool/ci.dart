// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

void main(List<String> arguments) async {
  final parser = makeArgParser();

  final ArgResults argResults = parser.parse(arguments);

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

  if (argResults['pub'] as bool) {
    const paths = [
      '.',
      'pkgs/hooks_runner/test_data/native_add_version_skew/',
      'pkgs/hooks_runner/test_data/native_add_version_skew_2/',
    ];
    for (final path in paths) {
      _runProcess('dart', ['pub', 'get', '--directory', path]);
    }
  }

  if (argResults['analyze'] as bool) {
    _runProcess('dart', ['analyze', '--fatal-infos', ...packages]);
  }

  if (argResults['format'] as bool) {
    _runProcess('dart', [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      ...packages,
    ]);
  }

  if (argResults['generate'] as bool) {
    const generators = [
      'pkgs/hooks/tool/generate_schemas.dart',
      'pkgs/hooks/tool/generate_syntax.dart',
      'pkgs/hooks/tool/normalize.dart',
    ];
    for (final generator in generators) {
      _runProcess('dart', [generator, '--set-exit-if-changed']);
    }
  }

  if (argResults['test'] as bool) {
    final testUris = getTestUris(packages);
    _runProcess('dart', ['test', ...testUris]);
  }

  if (argResults['example'] as bool) {
    const examplesWithTest = [
      'native_dynamic_linking',
      'native_add_app',
      'use_dart_api',
      'download_asset',
      'system_library',
    ];
    for (final exampleWithTest in examplesWithTest) {
      _runProcess(
        workingDirectory: repositoryRoot.resolve(
          'pkgs/hooks/example/build/$exampleWithTest/',
        ),
        'dart',
        ['--enable-experiment=native-assets', 'test'],
      );
    }

    _runProcess(
      workingDirectory: repositoryRoot.resolve(
        'pkgs/hooks/example/build/native_add_app/',
      ),
      'dart',
      ['--enable-experiment=native-assets', 'run'],
    );
    _runProcess(
      workingDirectory: repositoryRoot.resolve(
        'pkgs/hooks/example/build/native_add_app/',
      ),
      'dart',
      ['--enable-experiment=native-assets', 'build', 'bin/native_add_app.dart'],
    );
    _runProcess(
      repositoryRoot
          .resolve(
            'pkgs/hooks/example/build/native_add_app/bin/native_add_app/native_add_app.exe',
          )
          .toFilePath(),
      [],
    );
  }

  if (argResults['coverage'] as bool) {
    final testUris = getTestUris(packages);
    final scopeOutputs = [
      for (final testUri in testUris) Uri.directory(testUri).pathSegments[1],
    ];
    if (argResults['pub'] as bool) {
      _runProcess('dart', ['pub', 'global', 'activate', 'coverage']);
    }
    _runProcess('dart', [
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

ArgParser makeArgParser() {
  final parser =
      ArgParser()
        ..addFlag(
          'help',
          abbr: 'h',
          negatable: false,
          help: 'Prints this help message.',
        )
        ..addFlag(
          'analyze',
          defaultsTo: true,
          help: 'Run `dart analyze` on the packages.',
        )
        ..addFlag(
          'coverage',
          defaultsTo: true,
          help: 'Run `dart run coverage:test_with_coverage` on the packages.',
        )
        ..addFlag(
          'example',
          defaultsTo: true,
          help: 'Run tests and executables for examples.',
        )
        ..addFlag(
          'format',
          defaultsTo: true,
          help: 'Run `dart format` on the packages.',
        )
        ..addFlag(
          'generate',
          defaultsTo: true,
          help: 'Run code generation scripts.',
        )
        ..addFlag(
          'pub',
          defaultsTo: false,
          help:
              'Run `dart pub get` on the root and non-workspace packages.\n'
              'Run `dart pub global activate coverage`.',
        )
        ..addFlag(
          'test',
          defaultsTo: false,
          help: 'Run `dart test` on the packages.',
        );
  return parser;
}

final Uri repositoryRoot = Platform.script.resolve('../');

/// Load the root packages from the workspace. Omit nested test/example packages.
List<String> loadPackagesFromPubspec() {
  final pubspecYaml = loadYaml(
    File.fromUri(repositoryRoot.resolve('pubspec.yaml')).readAsStringSync(),
  );
  final workspace = (pubspecYaml['workspace'] as List).cast<String>();
  final packages =
      workspace
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

void _runProcess(
  String executable,
  List<String> arguments, {
  Uri? workingDirectory,
}) {
  var commandString = '$executable ${arguments.join(' ')}';
  if (workingDirectory != null) {
    commandString = 'cd ${workingDirectory.toFilePath()} && $commandString';
  }
  print('+$commandString');
  final result = Process.runSync(
    executable,
    arguments,
    workingDirectory: workingDirectory?.toFilePath(),
    stderrEncoding: utf8, // Make ✓ from `dart test` show up on GitHub UI.
    stdoutEncoding: utf8,
  );

  if (result.stdout.toString().isNotEmpty) {
    print(result.stdout);
  }
  if (result.stderr.toString().isNotEmpty) {
    print(result.stderr);
  }
  if (result.exitCode != 0) {
    print('+$commandString failed with exitCode ${result.exitCode}.');
    exit(result.exitCode);
  }
}

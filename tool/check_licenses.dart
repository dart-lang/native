// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';

const _licenseHeader = '''
// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''';

const _licenseTestString = 'Copyright (c) ';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      'set-exit-if-changed',
      negatable: false,
      help: 'Return a non-zero exit code if any files were changed.',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Prints this help message.',
    );

  final argResults = parser.parse(arguments);

  if (argResults['help'] as bool) {
    print('Usage: dart tool/check_licenses.dart [directories]');
    print(parser.usage);
    return;
  }

  final directories = argResults.rest.isEmpty ? ['.'] : argResults.rest;
  final setExitIfChanged = argResults['set-exit-if-changed'] as bool;

  var generatedCount = 0;
  var changedCount = 0;

  final stopwatch = Stopwatch()..start();

  for (final dirPath in directories) {
    final directory = Directory(dirPath);
    if (!directory.existsSync()) {
      print('Directory not found: $dirPath');
      continue;
    }

    await for (final file in directory.list(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) {
        continue;
      }

      if (_isIgnored(file.path)) {
        continue;
      }

      generatedCount++;

      final contents = await file.readAsString();
      if (_fileIsGenerated(contents, file.path)) {
        continue;
      }

      if (!contents.contains(_licenseTestString)) {
        print('Adding license header to ${file.path}');
        final newContents = '${_licenseHeader.trimLeft()}\n$contents';
        await file.writeAsString(newContents);
        changedCount++;
      }
    }
  }

  final seconds = stopwatch.elapsedMilliseconds / 1000.0;
  print(
    'Checked $generatedCount files ($changedCount changed) in '
    '${seconds.toStringAsFixed(2)} seconds.',
  );

  if (setExitIfChanged && changedCount > 0) {
    exit(1);
  }
}

bool _isIgnored(String filePath) {
  final segments = filePath.split(RegExp(r'[/\\]'));
  for (var i = 0; i < segments.length; i++) {
    final segment = segments[i];
    if (segment == '.dart_tool' || segment == '.git' || segment == '.jj') {
      return true;
    }
    if (segment == 'build') {
      // Only ignore 'build' if it's a sibling of 'pubspec.yaml'.
      final parentPath = segments.take(i).join(Platform.pathSeparator);
      final pubspec = File(
        parentPath.isEmpty
            ? 'pubspec.yaml'
            : '$parentPath${Platform.pathSeparator}pubspec.yaml',
      );
      if (pubspec.existsSync()) {
        return true;
      }
    }
  }
  return false;
}

bool _fileIsGenerated(String fileContents, String filePath) =>
    filePath.endsWith('.g.dart') ||
    fileContents
        .split('\n')
        .map((line) => line.trim())
        .takeWhile((line) => line.startsWith('//') || line.isEmpty)
        .any((line) => line.toLowerCase().contains('generate'));

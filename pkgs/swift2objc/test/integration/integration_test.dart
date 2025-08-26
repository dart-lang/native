// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Tests that every *_input.swift in this directory produces *_output.swift.
// Also tests that the generated output compiles without errors.

// This test is run in the usual way through dart test, but can also be run
// standalone, passing flags to run specific integration tests and to regenerate
// the expected outputs:
// dart test/integration/integration_test.dart --regen
// dart test/integration/integration_test.dart --regen nested_types
// dart test/integration/integration_test.dart nested_types structs_and_methods

import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:swift2objc/swift2objc.dart';
import 'package:test/test.dart';

import '../utils.dart';

// Hard coded sets of declarations to include, for tests where that matters.
final _includes = <String, Set<String>>{
  // 'url': {'urlFunc', 'NSURL'},
};

void main([List<String>? args]) {
  const inputSuffix = '_input.swift';
  const outputSuffix = '_output.swift';

  final thisDir = path.join(testDir, 'integration');
  final tempDir = path.join(thisDir, 'temp');

  var regen = false;
  final testNames = <String>[];
  if (args != null) {
    final p = ArgParser()..addFlag('regen', callback: (value) => regen = value);
    testNames.addAll(p.parse(args).rest);
  }
  if (testNames.isEmpty) {
    for (final entity in Directory(thisDir).listSync()) {
      final filename = path.basename(entity.path);
      if (filename.endsWith(inputSuffix)) {
        testNames.add(
          filename.substring(0, filename.length - inputSuffix.length),
        );
      }
    }
  }

  var loggedErrors = 0;
  Logger.root.onRecord.listen((record) {
    // stderr.writeln('${record.level.name}: ${record.message}');
    if (record.level >= Level.WARNING) ++loggedErrors;
  });

  group('Integration tests', () {
    for (final name in testNames) {
      test(name, () async {
        loggedErrors = 0;
        final inputFile = path.join(thisDir, '$name$inputSuffix');
        final expectedOutputFile = path.join(thisDir, '$name$outputSuffix');
        final actualOutputFile = regen
            ? expectedOutputFile
            : path.join(tempDir, '$name$outputSuffix');

        await generateWrapper(
          Config(
            inputs: [
              FilesInputConfig(files: [Uri.file(inputFile)])
            ],
            outputFile: Uri.file(actualOutputFile),
            tempDir: Directory(tempDir).uri,
            preamble: '// Test preamble text',
            include: (d) => _includes[name]?.contains(d.name) ?? true,
          ),
        );

        final actualOutput = await File(actualOutputFile).readAsString();
        final expectedOutput = File(expectedOutputFile).readAsStringSync();

        expect(actualOutput, expectedOutput);

        // await expectValidSwift([inputFile, actualOutputFile]);
      }, timeout: Timeout(const Duration(minutes: 2)));
    }
  });
}

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

void main([List<String>? args]) {
  const inputSuffix = '_input.swift';
  const outputSuffix = '_output.swift';

  final thisDir = path.join(Directory.current.path, 'test/integration');
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
        testNames
            .add(filename.substring(0, filename.length - inputSuffix.length));
      }
    }
  }

  Logger.root.onRecord.listen((record) {
    stderr.writeln('${record.level.name}: ${record.message}');
  });

  group('Integration tests', () {
    for (final name in testNames) {
      test(name, () async {
        final inputFile = path.join(thisDir, '$name$inputSuffix');
        final expectedOutputFile = path.join(thisDir, '$name$outputSuffix');
        final actualOutputFile = regen
            ? expectedOutputFile
            : path.join(tempDir, '$name$outputSuffix');

        await generateWrapper(Config(
          input: FilesInputConfig(
            files: [Uri.file(inputFile)],
          ),
          outputFile: Uri.file(actualOutputFile),
          tempDir: Directory(tempDir).uri,
          preamble: '// Test preamble text',
        ));

        final actualOutput = await File(actualOutputFile).readAsString();
        final expectedOutput = File(expectedOutputFile).readAsStringSync();

        expect(actualOutput, expectedOutput);

        // Try generating symbolgraph for input & output files
        // to make sure the result compiles. Input file must be included cause
        // it contains the definition of the entities the output code wraps.
        final symbolgraphCommand = FilesInputConfig(
          files: [
            Uri.file(inputFile),
            Uri.file(actualOutputFile),
          ],
          generatedModuleName: 'output_file_symbolgraph',
        ).symbolgraphCommand!;

        final processResult = await Process.run(
          symbolgraphCommand.executable,
          symbolgraphCommand.args,
          workingDirectory: tempDir,
        );

        if (processResult.exitCode != 0) {
          print(processResult.stdout);
          print(processResult.stderr);
        }
        expect(processResult.exitCode, 0);
      });
    }
  });
}

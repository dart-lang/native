// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:swift2objc/swift2objc.dart';
import 'package:test/test.dart';

const regenerateExpectedOutputs = true;

void main() {
  Logger.root.onRecord.listen((record) {
    stderr.writeln('${record.level.name}: ${record.message}');
  });

  group('Integration tests', () {
    const inputSuffix = '_input.swift';
    const outputSuffix = '_output.swift';

    final thisDir = path.join(Directory.current.path, 'test/integration');
    final tempDir = path.join(thisDir, 'temp');

    final names = <String>[];
    for (final entity in Directory(thisDir).listSync()) {
      final filename = path.basename(entity.path);
      if (filename.endsWith(inputSuffix)) {
        names.add(filename.substring(0, filename.length - inputSuffix.length));
      }
    }

    for (final name in names) {
      test(name, () async {
        final inputFile = path.join(thisDir, '$name$inputSuffix');
        final expectedOutputFile = path.join(thisDir, '$name$outputSuffix');
        final actualOutputFile = regenerateExpectedOutputs
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

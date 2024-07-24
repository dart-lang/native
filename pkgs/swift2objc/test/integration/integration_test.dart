// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:swift2objc/swift2objc.dart';
import 'package:test/test.dart';

void main() {
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
        final actualOutputFile = path.join(tempDir, '$name$outputSuffix');

        await generateWrapper(Config(
          inputFiles: [inputFile],
          outputFile: actualOutputFile,
          tempDir: Directory(tempDir),
          deleteTempAfterDone: false,
        ));

        final actualOutput = await File(actualOutputFile).readAsString();
        final expectedOutput = File(expectedOutputFile).readAsStringSync();

        expect(actualOutput, expectedOutput);
      });
    }
  });
}

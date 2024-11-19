// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:swift2objc/swift2objc.dart';
import 'package:test/test.dart';

void main() {
  group('Unit test for filter', () {
    final thisDir = path.join(Directory.current.path, 'test/unit');

    final file = path.join(thisDir, 'filter_test_input.swift');
    final output = path.join(thisDir, 'filter_test_output.swift');
      test(path.basename(file), () async {
        final actualOutputFile = path.join(thisDir, path.basename(output));

        await generateWrapper(Config(
          input: FilesInputConfig(
            files: [Uri.file(file)],
          ),
          outputFile: Uri.file(actualOutputFile),
          tempDir: Directory(thisDir).uri,
          preamble: '// Test preamble text',
          include: (declaration) => false,
        ));

        final actualOutput = await File(actualOutputFile).readAsString();
        final expectedOutput = File(output).readAsStringSync();

        expect(actualOutput, expectedOutput);
      }
    );

    tearDown(() {
      if (File(path.join(thisDir, 'symbolgraph_module.abi.json')).existsSync()) {
        File(path.join(thisDir, 'symbolgraph_module.abi.json')).deleteSync();
      }
      if (File(path.join(thisDir, 'symbolgraph_module.swiftdoc')).existsSync()) {
        File(path.join(thisDir, 'symbolgraph_module.swiftdoc')).deleteSync();
      }
      if (File(path.join(thisDir, 'symbolgraph_module.swiftmodule')).existsSync()) {
        File(path.join(thisDir, 'symbolgraph_module.swiftmodule')).deleteSync();
      }
      if (File(path.join(thisDir, 'symbolgraph_module.swiftsource')).existsSync()) {
        File(path.join(thisDir, 'symbolgraph_module.swiftsource')).deleteSync();
      }
      if (File(path.join(thisDir, 'symbolgraph_module.symbols.json')).existsSync()) {
        File(path.join(thisDir, 'symbolgraph_module.symbols.json')).deleteSync();
      }
      if (File(path.join(thisDir, 'symbolgraph_module.swiftsourceinfo')).existsSync()) {
        File(path.join(thisDir, 'symbolgraph_module.swiftsourceinfo')).deleteSync();
      }
    });
  });
}
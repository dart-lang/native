// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';
import 'package:swift2objc/swift2objc.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main([List<String>? args]) {
  final regen = args == null
      ? false
      : (ArgParser()..addFlag('regen')).parse(args).flag('regen');

  group('Unit test for filter', () {
    final thisDir = p.join(testDir, 'unit');
    final inputFile = p.join(thisDir, 'filter_test_input.swift');

    Future<void> runTest(String expectedOutputFile,
        bool Function(Declaration declaration) include) async {
      final output = p.join(thisDir, expectedOutputFile);
      final actualOutputFile = p.join(
        thisDir,
        '${p.basenameWithoutExtension(output)}.g.swift',
      );

      await generateWrapper(
        Config(
          input: FilesInputConfig(files: [Uri.file(inputFile)]),
          outputFile: Uri.file(actualOutputFile),
          tempDir: Directory(thisDir).uri,
          preamble: '// Test preamble text',
          include: include,
        ),
      );

      if (regen) {
        File(actualOutputFile).copySync(output);
      } else {
        final actualOutput = File(actualOutputFile).readAsStringSync();
        final expectedOutput = File(output).readAsStringSync();

        expectString(actualOutput, expectedOutput);
      }
      await expectValidSwift([inputFile, actualOutputFile]);
    }

    test('A: Filtering by name', () async {
      await runTest('filter_test_output_a.swift',
          (declaration) => declaration.name == 'Engine');
    });

    test('B: Filtering by type', () async {
      await runTest('filter_test_output_b.swift',
          (declaration) => declaration is ClassDeclaration);
    });

    test('C: Nonexistent declaration', () async {
      await runTest('filter_test_output_c.swift',
          (declaration) => declaration.name == 'Ship');
    });

    test('D: Stubbed declarations', () async {
      await runTest('filter_test_output_d.swift',
          (declaration) => declaration.name == 'Vehicle');
    });

    test('E: Nested declarations, child included, parent excluded', () async {
      // Parent should be stubbed.
      await runTest('filter_test_output_e.swift',
          (declaration) => declaration.name == 'Door');
    });

    test('F: Nested declarations, child stubbed, parent excluded', () async {
      // Parent should be stubbed.
      await runTest('filter_test_output_f.swift',
          (declaration) => declaration.name == 'openDoor');
    });

    test('G: Nested declarations, child excluded, parent included', () async {
      // Child should be stubbed.
      await runTest('filter_test_output_g.swift',
          (declaration) => declaration.name == 'Garage');
    });

    test('H: Nested declarations, child excluded, parent stubbed', () async {
      // Child should be omitted.
      await runTest('filter_test_output_h.swift',
          (declaration) => declaration.name == 'listGarageVehicles');
    });

    tearDown(() {
      void tryDelete(FileSystemEntity file) {
        if (file is File && file.existsSync()) file.deleteSync();
      }

      tryDelete(File(p.join(thisDir, 'symbolgraph_module.abi.json')));
      tryDelete(File(p.join(thisDir, 'symbolgraph_module.swiftdoc')));
      tryDelete(File(p.join(thisDir, 'symbolgraph_module.swiftmodule')));
      tryDelete(File(p.join(thisDir, 'symbolgraph_module.swiftsource')));
      tryDelete(File(p.join(thisDir, 'symbolgraph_module.symbols.json')));
      tryDelete(File(p.join(thisDir, 'symbolgraph_module.swiftsourceinfo')));

      Directory(thisDir)
          .listSync()
          .where((t) => p.extension(t.path, 2) == '.g.swift')
          .forEach(tryDelete);
    });
  });
}

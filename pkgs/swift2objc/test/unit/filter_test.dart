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
    final tempDir = p.join(thisDir, 'temp');
    final inputFile = p.join(thisDir, 'filter_test_input.swift');

    void filterTest(
      String name,
      String expectedOutputFile,
      bool Function(Declaration declaration) include,
    ) {
      test(name, () async {
        final output = p.join(thisDir, expectedOutputFile);
        final actualOutputFile = p.join(
          tempDir,
          '${p.basenameWithoutExtension(output)}.g.swift',
        );

        await generateWrapper(
          Config(
            inputs: [
              FilesInputConfig(files: [Uri.file(inputFile)]),
            ],
            outputFile: Uri.file(actualOutputFile),
            tempDir: Directory(tempDir).uri,
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
      }, timeout: const Timeout(Duration(minutes: 2)));
    }

    filterTest(
      'A: Filtering by name',
      'filter_test_output_a.swift',
      (declaration) => declaration.name == 'Engine',
    );

    filterTest(
      'B: Filtering by type',
      'filter_test_output_b.swift',
      (declaration) => declaration is ClassDeclaration,
    );

    filterTest(
      'C: Nonexistent declaration',
      'filter_test_output_c.swift',
      (declaration) => declaration.name == 'Ship',
    );

    filterTest(
      'D: Stubbed declarations',
      'filter_test_output_d.swift',
      (declaration) => declaration.name == 'Vehicle',
    );

    // Parent should be stubbed.
    filterTest(
      'E: Nested declarations, child included, parent excluded',
      'filter_test_output_e.swift',
      (declaration) => declaration.name == 'Door',
    );

    // Parent should be stubbed.
    filterTest(
      'F: Nested declarations, child stubbed, parent excluded',
      'filter_test_output_f.swift',
      (declaration) => declaration.name == 'openDoor',
    );

    // Child should be stubbed.
    filterTest(
      'G: Nested declarations, child excluded, parent included',
      'filter_test_output_g.swift',
      (declaration) => declaration.name == 'Garage',
    );

    // Child should be omitted.
    filterTest(
      'H: Nested declarations, child excluded, parent stubbed',
      'filter_test_output_h.swift',
      (declaration) => declaration.name == 'listGarageVehicles',
    );
  });
}

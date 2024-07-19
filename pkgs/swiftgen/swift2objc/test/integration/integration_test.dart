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
    const symbolSuffix = '_input.symbols.json';
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
        final symbolFile = path.join(tempDir, '$name$symbolSuffix');
        final actualOutputFile = path.join(tempDir, '$name$outputSuffix');

        expect(await generateSymbolGraph(inputFile, tempDir), isTrue);
        expect(File(symbolFile).existsSync(), isTrue);

        final declarations = parseAst(symbolFile);
        final transformedDeclarations = transform(declarations);
        final actualOutput = generate(transformedDeclarations);
        File(actualOutputFile).writeAsStringSync(actualOutput);

        final expectedOutput = File(expectedOutputFile).readAsStringSync();
        expect(actualOutput, expectedOutput);
      });
    }
  });
}

Future<bool> generateSymbolGraph(String swiftFile, String outputDir) async {
  final result = await Process.run(
    'swiftc',
    [
      swiftFile,
      '-emit-module',
      '-emit-symbol-graph',
      '-emit-symbol-graph-dir',
      '.',
    ],
    workingDirectory: outputDir,
  );
  if (result.exitCode != 0) {
    print('Error generating symbol graph');
    print(result.stdout);
    print(result.stderr);
    return false;
  }
  return true;
}

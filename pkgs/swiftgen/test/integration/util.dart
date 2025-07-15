// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart' as fg;
import 'package:logging/logging.dart';
import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:path/path.dart' as path;
import 'package:swiftgen/src/util.dart';
import 'package:swiftgen/swiftgen.dart';
import 'package:test/test.dart';

String pkgDir = findPackageRoot('swiftgen').toFilePath();

// TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
String objCTestDylib = path.join(
  pkgDir,
  '..',
  'objective_c',
  'test',
  'objective_c.dylib',
);

class TestGenerator {
  final String name;
  late final String testDir;
  late final String tempDir;
  late final String inputFile;
  late final String outputFile;
  late final String outputObjCFile;
  late final String objInputFile;
  late final String objWrapperFile;
  late final String objObjCFile;
  late final String dylibFile;
  late final String actualOutputFile;

  TestGenerator(this.name) {
    testDir = path.absolute(path.join(pkgDir, 'test/integration'));
    tempDir = path.join(testDir, 'temp');
    inputFile = path.join(testDir, '${name}_wrapper.swift');
    outputFile = path.join(tempDir, '${name}_output.dart');
    outputObjCFile = path.join(tempDir, '${name}_output.m');
    objInputFile = path.join(tempDir, '$name.o');
    objWrapperFile = path.join(tempDir, '${name}_wrapper.o');
    objObjCFile = path.join(tempDir, '${name}_output_m.o');
    dylibFile = path.join(tempDir, '$name.dylib');
    actualOutputFile = path.join(testDir, '${name}_bindings.dart');
  }

  Future<void> generateBindings() async => SwiftGen(
    target: await Target.host(),
    input: ObjCCompatibleSwiftFileInput(
      module: name,
      files: [Uri.file(inputFile)],
    ),
    tempDirectory: Directory(tempDir).uri,
    ffigen: FfiGenConfig(
      output: Uri.file(outputFile),
      outputObjC: Uri.file(outputObjCFile),
      objcInterfaces: fg.DeclarationFilters(
        shouldInclude: (decl) => decl.originalName.startsWith('Test'),
      ),
      preamble: '''
// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unnecessary_non_null_assertion
// ignore_for_file: unused_element
// ignore_for_file: unused_field
// coverage:ignore-file
''',
    ),
  ).generate(Logger.root..level = Level.SEVERE);

  Future<void> generateAndVerifyBindings() async {
    // Run the generation pipeline. This produces the swift compatability
    // wrapper, and the ffigen wrapper.
    await generateBindings();

    expect(File(inputFile).existsSync(), isTrue);
    expect(File(outputFile).existsSync(), isTrue);
    expect(File(outputObjCFile).existsSync(), isTrue);

    // The generation pipeline also creates some obj files as a byproduct.
    expect(File(objWrapperFile).existsSync(), isTrue);

    // We also need to compile outputObjCFile to an obj file.
    await run('clang', [
      '-x',
      'objective-c',
      '-fobjc-arc',
      '-c',
      outputObjCFile,
      '-fpic',
      '-o',
      objObjCFile,
    ], tempDir);
    expect(File(objObjCFile).existsSync(), isTrue);

    // Link all the obj files into a dylib.
    await run('clang', [
      '-shared',
      '-framework',
      'Foundation',
      objWrapperFile,
      objObjCFile,
      '-o',
      dylibFile,
    ], tempDir);
    expect(File(dylibFile).existsSync(), isTrue);
  }
}

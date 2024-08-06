// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:swiftgen/src/util.dart';
import 'package:swiftgen/swiftgen.dart';
import 'package:test/test.dart';

class TestGenerator {
  final String name;
  late final String testDir;
  late final String tempDir;
  late final String inputFile;
  late final String wrapperFile;
  late final String outputFile;
  late final String outputObjCFile;
  late final String objInputFile;
  late final String objWrapperFile;
  late final String objObjCFile;
  late final String dylibFile;
  late final String actualOutputFile;

  TestGenerator(this.name) {
    testDir = path.absolute(path.join(Directory.current.path, 'test/integration'));
    tempDir = path.join(testDir, 'temp');
    inputFile = path.join(testDir, '${name}.swift');
    wrapperFile = path.join(tempDir, '${name}_wrapper.swift');
    outputFile = path.join(tempDir, '${name}_output.dart');
    outputObjCFile = path.join(tempDir, '${name}_output.m');
    objInputFile = path.join(tempDir, '${name}.o');
    objWrapperFile = path.join(tempDir, '${name}_wrapper.o');
    objObjCFile = path.join(tempDir, '${name}_output_m.o');
    dylibFile = path.join(tempDir, '${name}.dylib');
    actualOutputFile = path.join(testDir, '${name}_bindings.dart');
  }

  Future<void> generateBindings() async => generate(Config(
      target: await Target.host(),
      input: SwiftFileInput(
        module: name,
        files: [Uri.file(inputFile)],
      ),
      objcSwiftFile: Uri.file(wrapperFile),
      tempDir: Directory(tempDir).uri,
      ffigen: FfiGenConfig(
        output: Uri.file(outputFile),
        outputObjC: Uri.file(outputObjCFile),
        objcInterfaces: DeclarationFilters(
          shouldInclude: (decl) => decl.originalName.startsWith('Test'),
        ),
      ),
    ));

  Future<void> generateAndVerifyBindings() async {
    // Run the generation pipeline. This produces the swift compatability
    // wrapper, and the ffigen wrapper.
    await generateBindings();

    expect(File(wrapperFile).existsSync(), isTrue);
    expect(File(outputFile).existsSync(), isTrue);
    expect(File(outputObjCFile).existsSync(), isTrue);

    // The generation pipeline also creates some obj files as a byproduct.
    expect(File(objInputFile).existsSync(), isTrue);
    expect(File(objWrapperFile).existsSync(), isTrue);

    // We also need to compile outputObjCFile to an obj file.
    await run('clang',
      ['-x', 'objective-c', '-c', outputObjCFile, '-fpic', '-o', objObjCFile],
      tempDir);
    expect(File(objObjCFile).existsSync(), isTrue);

    // Link all the obj files into a dylib.
    await run('clang',
      ['-shared', '-framework', 'Foundation', objInputFile,
          objWrapperFile, objObjCFile, '-o', dylibFile],
      tempDir);
    expect(File(dylibFile).existsSync(), isTrue);
  }
}

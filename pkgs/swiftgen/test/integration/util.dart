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

Future<Target> hostTarget = Target.host();

// There are language features that aren't supported in Swift2ObjC yet, but that
// we want to test in SwiftGen. So for now we write @objc annotated bindings for
// these features. As each of these features is supported, migrate the test to
// stop using hand-written @objc annotations.
// TODO(https://github.com/dart-lang/native/issues/1669): callbacks
// TODO(https://github.com/dart-lang/native/issues/1828): protocols
const objCCompatibleTests = {'callbacks', 'protocols'};

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
  final bool isObjCCompatible;

  TestGenerator(this.name)
    : isObjCCompatible = objCCompatibleTests.contains(name) {
    testDir = path.absolute(path.join(pkgDir, 'test/integration'));
    tempDir = path.join(testDir, 'temp with spaces');
    inputFile = path.join(testDir, '$name.swift');
    wrapperFile = path.join(tempDir, '${name}_wrapper.swift');
    outputFile = path.join(tempDir, '${name}_output.dart');
    outputObjCFile = path.join(tempDir, '${name}_output.m');
    objInputFile = path.join(tempDir, '$name.o');
    objWrapperFile = path.join(tempDir, '${name}_wrapper.o');
    objObjCFile = path.join(tempDir, '${name}_output_m.o');
    dylibFile = path.join(tempDir, '$name.dylib');
    actualOutputFile = path.join(testDir, '${name}_bindings.dart');
  }

  Future<void> generateBindings() async =>
      await SwiftGenerator(
        target: await hostTarget,
        inputs: [
          isObjCCompatible
              ? ObjCCompatibleSwiftFileInput(files: [Uri.file(inputFile)])
              : SwiftFileInput(files: [Uri.file(inputFile)]),
        ],
        output: Output(
          swiftWrapperFile: isObjCCompatible
              ? null
              : SwiftWrapperFile(path: Uri.file(wrapperFile)),
          module: name,
          dartFile: Uri.file(outputFile),
          objectiveCFile: Uri.file(outputObjCFile),
          preamble: '''
// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// coverage:ignore-file
''',
        ),
        ffigen: FfiGeneratorOptions(
          objectiveC: fg.ObjectiveC(
            interfaces: fg.Interfaces(
              include: (decl) => decl.originalName.startsWith('Test'),
            ),
            protocols: fg.Protocols(
              include: (decl) => decl.originalName.startsWith('Test'),
            ),
          ),
        ),
      ).generate(
        logger: Logger.root..level = Level.SEVERE,
        tempDirectory: Uri.directory(tempDir),
      );

  Future<void> generateAndVerifyBindings() async {
    // Run the generation pipeline. This produces the swift compatability
    // wrapper, and the ffigen wrapper.
    await generateBindings();

    expect(File(inputFile).existsSync(), isTrue);
    expect(File(wrapperFile).existsSync(), !isObjCCompatible);
    expect(File(outputFile).existsSync(), isTrue);

    // The generation pipeline also an obj file as a byproduct.
    expect(File(objInputFile).existsSync(), isTrue);

    final target = await hostTarget;
    await run('swiftc', [
      '-c',
      inputFile,
      if (!isObjCCompatible) wrapperFile,
      '-module-name',
      name,
      '-target',
      target.triple,
      '-sdk',
      path.absolute(target.sdk.toFilePath()),
    ], tempDir);

    final hasOutputObjCFile = File(outputObjCFile).existsSync();
    if (hasOutputObjCFile) {
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
    }

    // Link all the obj files into a dylib.
    await run('clang', [
      '-shared',
      '-framework',
      'Foundation',
      objInputFile,
      if (!isObjCCompatible) objWrapperFile,
      if (hasOutputObjCFile) objObjCFile,
      '-o',
      dylibFile,
    ], tempDir);
    expect(File(dylibFile).existsSync(), isTrue);

    // Expect that the bindings match.
    expect(
      File(outputFile).readAsStringSync(),
      File(actualOutputFile).readAsStringSync(),
    );
  }
}

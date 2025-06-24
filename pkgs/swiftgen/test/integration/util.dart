// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:swiftgen/src/util.dart';
import 'package:swiftgen/swiftgen.dart';
import 'package:test/test.dart';

String pkgDir = findPackageRoot('swiftgen').toFilePath();

// TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
String objCTestDylib = path.join(pkgDir, '..', 'objective_c', 'test', 'objective_c.dylib');

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
    objInputFile = path.join(tempDir, '${name}.o');
    objWrapperFile = path.join(tempDir, '${name}_wrapper.o');
    objObjCFile = path.join(tempDir, '${name}_output_m.o');
    dylibFile = path.join(tempDir, '${name}.dylib');
    actualOutputFile = path.join(testDir, '${name}_bindings.dart');
  }

  Future<void> generateBindings() async => generate(Config(
        target: await Target.host(),
        input: ObjCCompatibleSwiftFileInput(
          module: name,
          files: [Uri.file(inputFile)],
        ),
        tempDirectory: Directory(tempDir).uri,
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

    expect(File(inputFile).existsSync(), isTrue);
    expect(File(outputFile).existsSync(), isTrue);
    expect(File(outputObjCFile).existsSync(), isTrue);

    // The generation pipeline also creates some obj files as a byproduct.
    expect(File(objWrapperFile).existsSync(), isTrue);

    // We also need to compile outputObjCFile to an obj file.
    await run(
        'clang',
        [
          '-x',
          'objective-c',
          '-fobjc-arc',
          '-c',
          outputObjCFile,
          '-fpic',
          '-o',
          objObjCFile,
        ],
        tempDir);
    expect(File(objObjCFile).existsSync(), isTrue);

    // Link all the obj files into a dylib.
    await run(
        'clang',
        [
          '-shared',
          '-framework',
          'Foundation',
          objWrapperFile,
          objObjCFile,
          '-o',
          dylibFile
        ],
        tempDir);
    expect(File(dylibFile).existsSync(), isTrue);
  }
}

/// Test files are run in a variety of ways, find this package root in all.
///
/// Test files can be run from source from any working directory. The Dart SDK
/// `tools/test.py` runs them from the root of the SDK for example.
///
/// Test files can be run from dill from the root of package. `package:test`
/// does this.
///
/// https://github.com/dart-lang/test/issues/110
Uri findPackageRoot(String packageName) {
  final script = Platform.script;
  final fileName = script.name;
  if (fileName.endsWith('.dart')) {
    // We're likely running from source in the package somewhere.
    var directory = script.resolve('.');
    while (true) {
      final dirName = directory.name;
      if (dirName == packageName) {
        return directory;
      }
      final parent = directory.resolve('..');
      if (parent == directory) break;
      directory = parent;
    }
  } else if (fileName.endsWith('.dill')) {
    // Probably from the package root.
    final cwd = Directory.current.uri;
    final dirName = cwd.name;
    if (dirName == packageName) {
      return cwd;
    }
  }
  // Or the workspace root.
  final cwd = Directory.current.uri;
  final candidate = cwd.resolve('pkgs/$packageName/');
  if (Directory.fromUri(candidate).existsSync()) {
    return candidate;
  }
  throw StateError(
    "Could not find package root for package '$packageName'. "
    'Tried finding the package root via Platform.script '
    "'${Platform.script.toFilePath()}' and Directory.current "
    "'${Directory.current.uri.toFilePath()}'.",
  );
}

extension on Uri {
  String get name => pathSegments.where((e) => e != '').last;
}

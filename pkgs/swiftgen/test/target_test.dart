// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:swiftgen/swiftgen.dart';
import 'package:test/test.dart';

void main() {
  group('Target', () {
    test('is passed to Swift2ObjCGenerator for SwiftFileInput', () async {
      final tempDir = Directory.systemTemp.createTempSync('swiftgen_test');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final inputFile = path.join(tempDir.path, 'input.swift');
      File(inputFile).writeAsStringSync('public class TestClass {}');

      await expectTargetPassedToGeneratorCommand(
        tempDir: tempDir,
        executable: 'swiftc',
        generateWrapper: true,
        createGenerator: (target, output) => SwiftGenerator(
          target: target,
          inputs: [
            SwiftFileInput(files: [Uri.file(inputFile)]),
          ],
          output: output,
          ffigen: const FfiGeneratorOptions(),
        ),
      );
    });

    test('is passed to Swift2ObjCGenerator for SwiftModuleInput', () async {
      final tempDir = Directory.systemTemp.createTempSync('swiftgen_test');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      await expectTargetPassedToGeneratorCommand(
        tempDir: tempDir,
        executable: 'swift',
        generateWrapper: true,
        createGenerator: (target, output) => SwiftGenerator(
          target: target,
          inputs: [const SwiftModuleInput(module: 'TestModule')],
          output: output,
          ffigen: const FfiGeneratorOptions(),
        ),
      );
    });

    test('is passed to _generateObjCFile', () async {
      final tempDir = Directory.systemTemp.createTempSync('swiftgen_test');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final inputFile = path.join(tempDir.path, 'input.swift');
      File(inputFile).writeAsStringSync('''
import Foundation

@objc public class TestClass: NSObject {}
''');

      await expectTargetPassedToGeneratorCommand(
        tempDir: tempDir,
        executable: 'swiftc',
        generateWrapper: false,
        createGenerator: (target, output) => SwiftGenerator(
          target: target,
          inputs: [
            ObjCCompatibleSwiftFileInput(files: [Uri.file(inputFile)]),
          ],
          output: output,
          ffigen: const FfiGeneratorOptions(),
        ),
      );
    });
  });
}

Future<void> expectTargetPassedToGeneratorCommand({
  required Directory tempDir,
  required String executable,
  required bool generateWrapper,
  required SwiftGenerator Function(Target target, Output output)
  createGenerator,
}) async {
  final outputFile = path.join(tempDir.path, 'output.dart');
  final outputObjCFile = path.join(tempDir.path, 'output.m');
  final wrapperFile = path.join(tempDir.path, 'wrapper.swift');
  final sdkDir = path.join(tempDir.path, 'TestSDK.sdk');
  final target = Target(
    triple: 'arm64-apple-ios999.0',
    sdk: Uri.directory(sdkDir),
  );

  Directory(sdkDir).createSync();

  final output = Output(
    swiftWrapperFile: generateWrapper
        ? SwiftWrapperFile(path: Uri.file(wrapperFile))
        : null,
    module: 'TargetTest',
    dartFile: Uri.file(outputFile),
    objectiveCFile: Uri.file(outputObjCFile),
  );

  final generate = createGenerator(target, output).generate(
    logger: Logger.detached('test')..level = Level.OFF,
    tempDirectory: Uri.directory(tempDir.path),
  );

  final error = await generate.then<Object?>(
    (_) => null,
    onError: (Object error) => error,
  );

  expect(error, isA<ProcessException>());
  final exception = error as ProcessException;
  expect(exception.executable, executable);
  expect(exception.arguments, containsPair('-target', target.triple));
  expect(
    exception.arguments,
    containsPair('-sdk', path.absolute(target.sdk.toFilePath())),
  );
}

Matcher containsPair(String option, String value) =>
    predicate<List<String>>((arguments) {
      final index = arguments.indexOf(option);
      return index >= 0 &&
          index + 1 < arguments.length &&
          arguments[index + 1] == value;
    }, 'contains $option $value');

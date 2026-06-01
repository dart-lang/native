// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:swiftgen/swiftgen.dart';
import 'package:test/test.dart';

void main() {
  test('SwiftGenerator passes target and sdk to Swift2ObjCGenerator', () async {
    final tempDir = Directory.systemTemp.createTempSync('swiftgen_test');
    try {
      final outputFile = p.join(tempDir.path, 'output.dart');
      final objectiveCFile = p.join(tempDir.path, 'output.m');
      final swiftWrapperFile = p.join(tempDir.path, 'wrapper.swift');
      final dummySwiftFile = p.join(tempDir.path, 'input.swift');
      File(dummySwiftFile).writeAsStringSync('class Foo {}');

      final target = Target(
        triple: 'invalid-triple',
        sdk: Uri.file('/non/existent/sdk'),
      );

      final generator = SwiftGenerator(
        target: target,
        inputs: [
          SwiftFileInput(files: [Uri.file(dummySwiftFile)]),
        ],
        output: Output(
          module: 'TestModule',
          dartFile: Uri.file(outputFile),
          objectiveCFile: Uri.file(objectiveCFile),
          swiftWrapperFile: SwiftWrapperFile(path: Uri.file(swiftWrapperFile)),
        ),
        ffigen: const FfiGeneratorOptions(),
      );

      try {
        await generator.generate(logger: Logger.root);
        fail('Should have thrown an exception');
      } catch (e) {
        // The error should contain both the invalid triple and the invalid SDK
        // because they are passed to swiftc.
        expect(e.toString(), contains('invalid-triple'));
        expect(e.toString(), contains('/non/existent/sdk'));
      }
    } finally {
      tempDir.deleteSync(recursive: true);
    }
  });

  test(
    'SwiftGenerator passes target & sdk to Swift2ObjCGenerator for SwiftModuleInput',
    () async {
      final tempDir = Directory.systemTemp.createTempSync(
        'swiftgen_test_module',
      );
      try {
        final outputFile = p.join(tempDir.path, 'output.dart');
        final objectiveCFile = p.join(tempDir.path, 'output.m');
        final swiftWrapperFile = p.join(tempDir.path, 'wrapper.swift');

        final target = Target(
          triple: 'invalid-triple-module',
          sdk: Uri.file('/non/existent/sdk/module'),
        );

        final generator = SwiftGenerator(
          target: target,
          inputs: [const SwiftModuleInput(module: 'SomeModule')],
          output: Output(
            module: 'TestModule',
            dartFile: Uri.file(outputFile),
            objectiveCFile: Uri.file(objectiveCFile),
            swiftWrapperFile: SwiftWrapperFile(
              path: Uri.file(swiftWrapperFile),
            ),
          ),
          ffigen: const FfiGeneratorOptions(),
        );

        try {
          await generator.generate(logger: Logger.root);
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e.toString(), contains('invalid-triple-module'));
          expect(e.toString(), contains('/non/existent/sdk/module'));
        }
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    },
  );

  test(
    'SwiftGenerator passes target and sdk to swiftc in _generateObjCFile',
    () async {
      final tempDir = Directory.systemTemp.createTempSync('swiftgen_test_objc');
      try {
        final outputFile = p.join(tempDir.path, 'output.dart');
        final objectiveCFile = p.join(tempDir.path, 'output.m');
        final dummySwiftFile = p.join(tempDir.path, 'input.swift');
        // Needs to be @objc to be compatible without a wrapper
        File(dummySwiftFile).writeAsStringSync(
          'import Foundation\n@objc public class Foo: NSObject {}',
        );

        final target = Target(
          triple: 'invalid-triple-objc',
          sdk: Uri.file('/non/existent/sdk/objc'),
        );

        final generator = SwiftGenerator(
          target: target,
          inputs: [
            ObjCCompatibleSwiftFileInput(files: [Uri.file(dummySwiftFile)]),
          ],
          output: Output(
            module: 'TestModule',
            dartFile: Uri.file(outputFile),
            objectiveCFile: Uri.file(objectiveCFile),
          ),
          ffigen: const FfiGeneratorOptions(),
        );

        try {
          await generator.generate(logger: Logger.root);
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e.toString(), contains('invalid-triple-objc'));
          expect(e.toString(), contains('/non/existent/sdk/objc'));
        }
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    },
  );
}

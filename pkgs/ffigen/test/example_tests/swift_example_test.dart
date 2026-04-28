// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Swift support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:async';
import 'dart:io';

import 'package:ffigen/src/header_parser.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('swift_example_test', () {
    test('swift', () async {
      // Run the swiftc command from the example README, to generate the header.
      final process = await Process.start('swiftc', [
        '-c',
        'swift_api.swift',
        '-module-name',
        'swift_module',
        '-emit-objc-header-path',
        'third_party/swift_api.h',
        '-emit-library',
        '-o',
        'libswiftapi.dylib',
      ], workingDirectory: path.join(packagePathForTests, 'example/swift'));
      unawaited(stdout.addStream(process.stdout));
      unawaited(stderr.addStream(process.stderr));
      final result = await process.exitCode;
      expect(result, 0);

      final context = testContext(
        testConfigFromPath(
          path.join(packagePathForTests, 'example', 'swift', 'config.yaml'),
        ),
      );

      matchLibraryWithExpected(
        context,
        parse(context),
        'swift_example.dart',
        ['example', 'swift', 'swift_api_bindings.dart'],
        verify: (expected, actual) {
          // Verify that the output contains all the methods and classes that
          // the example app uses.
          expect(
            actual,
            contains('extension type SwiftClass._(objc.ObjCObject '),
          );
          expect(actual, contains('static SwiftClass new\$() {'));
          expect(actual, contains('NSString sayHello() {'));
          expect(actual, contains('int get someField {'));
          expect(actual, contains('set someField(int value) {'));

          // Verify that SwiftClass is loaded using the swift_module prefix.
          expect(
            actual,
            contains(
              RegExp(
                r'late final _class_SwiftClass.* = '
                r'objc.getClass.*\("swift_module\.SwiftClass"\)',
              ),
            ),
          );

          return true;
        },
      );
    });
  });
}

// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('swift_unavailable', () {
    late final String bindings;

    setUpAll(() {
      FfiGenerator(
        output: Output(
          dartFile: Uri.file(
            path.join(
              packagePathForTests,
              'test',
              'native_objc_test',
              'swift_unavailable_bindings.dart',
            ),
          ),
          format: false,
          style: const DynamicLibraryBindings(
            wrapperName: 'SwiftUnavailableTestLibrary',
            wrapperDocComment: 'Tests SWIFT_UNAVAILABLE annotation',
          ),
        ),
        headers: Headers(
          entryPoints: [
            Uri.file(
              path.join(
                packagePathForTests,
                'test',
                'native_objc_test',
                'swift_unavailable_test.m',
              ),
            ),
          ],
        ),
        objectiveC: ObjectiveC(
          interfaces: Interfaces(
            include: (decl) => {'Animal'}.contains(decl.originalName),
          ),
        ),
      ).generate(logger: createTestLogger());

      bindings = File(
        path.join(
          packagePathForTests,
          'test',
          'native_objc_test',
          'swift_unavailable_bindings.dart',
        ),
      ).readAsStringSync();
    });

    test('initWithName is generated (designated initializer)', () {
      expect(bindings, contains('initWithName'));
    });

    test('init is NOT generated (SWIFT_UNAVAILABLE)', () {
      expect(RegExp(r"'init'\b").hasMatch(bindings), isFalse);
    });

    test('new is NOT generated (SWIFT_UNAVAILABLE_MSG)', () {
      expect(bindings, isNot(contains("'new'")));
    });

    test('no-arg Animal() constructor is NOT generated', () {
      expect(bindings, isNot(contains('Animal()')));
    });
  });
}

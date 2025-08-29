// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import '../test_utils.dart';

void main() {
  group('NSRange', () {
    late final String bindings;
    setUpAll(() {
      FfiGenerator(
        wrapperName: 'NSRangeTestObjCLibrary',
        language: Language.objc,
        output: Uri.file(
          path.join(
            packagePathForTests,
            'test',
            'native_objc_test',
            'ns_range_bindings.dart',
          ),
        ),
        entryPoints: [
          Uri.file(
            path.join(
              packagePathForTests,
              'test',
              'native_objc_test',
              'ns_range_test.m',
            ),
          ),
        ],
        formatOutput: false,
        objcInterfaces: DeclarationFilters.include({'SFTranscriptionSegment'}),
      ).generate(logger: Logger.root..level = Level.SEVERE);
      bindings = File(
        path.join(
          packagePathForTests,
          'test',
          'native_objc_test',
          'ns_range_bindings.dart',
        ),
      ).readAsStringSync();
    });

    test('interfaces', () {
      // Regression test for https://github.com/dart-lang/native/issues/1180.
      expect(
        bindings.split('\n'),
        isNot(contains(matches(RegExp(r'class.*NSRange.*Struct')))),
      );
    });
  });
}

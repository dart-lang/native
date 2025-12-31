// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:ffi';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'log_bindings.dart';
import 'util.dart';

void main() {
  group('log_test', () {
    setUpAll(() {
      final dylib = File(
        path.join(
          packagePathForTests,
          'test',
          'native_objc_test',
          'objc_test.dylib',
        ),
      );
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      generateBindingsForCoverage('log');
    });

    test('Duplicate method log spam', () {
      final logs = <String>[];
      final logger = createTestLogger(
        capturedMessages: logs,
        level: Level.SEVERE,
      );
      generateBindingsForCoverage('log', logger);
      expect(logs, isNot(contains(contains('matchingMethod'))));
      expect(logs, isNot(contains(contains('instancetypeMethod'))));
    });

    test('Instancetype method overridden by id method', () {
      // Test that we keep the instancetype version of the method. Specifically,
      // LogSpamChildClass.instancetypeMethod returns LogSpamChildClass rather
      // than ObjCObject.
      final LogSpamChildClass obj = LogSpamChildClass.instancetypeMethod();
      expect(LogSpamChildClass.isA(obj), isTrue);
    });
  });
}

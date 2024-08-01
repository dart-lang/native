// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
import 'log_bindings.dart';
import 'util.dart';

void main() {
  group('log_test', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/log_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      generateBindingsForCoverage('log');
    });

    test('Duplicate method log spam', () {
      final logs = <String>[];
      logToArray(logs, Level.SEVERE);
      generateBindingsForCoverage('log');
      expect(logs, isNot(contains(contains('matchingMethod'))));
      expect(logs, isNot(contains(contains('instancetypeMethod'))));
    });

    test('Instancetype method overridden by id method', () {
      // Test that we keep the instancetype version of the method. Specifically,
      // LogSpamChildClass.instancetypeMethod returns LogSpamChildClass rather
      // than ObjCObjectBase.
      final LogSpamChildClass obj = LogSpamChildClass.instancetypeMethod();
      expect(LogSpamChildClass.isInstance(obj), isTrue);
    });
  });
}

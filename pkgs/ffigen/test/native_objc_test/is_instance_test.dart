// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'is_instance_bindings.dart';
import 'util.dart';

void main() {
  group('isInstance', () {
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
      generateBindingsForCoverage('is_instance');
    });

    test('Unrelated classes', () {
      final base = NSObject.as(IsInstanceBaseClass());
      final unrelated = NSObject.as(IsInstanceUnrelatedClass());
      expect(IsInstanceBaseClass.isA(base), isTrue);
      expect(IsInstanceBaseClass.isA(unrelated), isFalse);
      expect(IsInstanceUnrelatedClass.isA(base), isFalse);
      expect(IsInstanceUnrelatedClass.isA(unrelated), isTrue);
    });

    test('Base class vs child class', () {
      final base = NSObject.as(IsInstanceBaseClass());
      final child = NSObject.as(IsInstanceChildClass());
      expect(IsInstanceBaseClass.isA(base), isTrue);
      expect(IsInstanceBaseClass.isA(child), isTrue);
      expect(IsInstanceChildClass.isA(base), isFalse);
      expect(IsInstanceChildClass.isA(child), isTrue);
    });
  });
}

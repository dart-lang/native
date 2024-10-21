// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
import 'is_instance_bindings.dart';
import 'util.dart';

void main() {
  group('isInstance', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/objc_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      generateBindingsForCoverage('is_instance');
    });

    test('Unrelated classes', () {
      final base = NSObject.castFrom(IsInstanceBaseClass.new1());
      final unrelated = NSObject.castFrom(IsInstanceUnrelatedClass.new1());
      expect(IsInstanceBaseClass.isInstance(base), isTrue);
      expect(IsInstanceBaseClass.isInstance(unrelated), isFalse);
      expect(IsInstanceUnrelatedClass.isInstance(base), isFalse);
      expect(IsInstanceUnrelatedClass.isInstance(unrelated), isTrue);
    });

    test('Base class vs child class', () {
      final base = NSObject.castFrom(IsInstanceBaseClass.new1());
      final child = NSObject.castFrom(IsInstanceChildClass.new1());
      expect(IsInstanceBaseClass.isInstance(base), isTrue);
      expect(IsInstanceBaseClass.isInstance(child), isTrue);
      expect(IsInstanceChildClass.isInstance(base), isFalse);
      expect(IsInstanceChildClass.isInstance(child), isTrue);
    });
  });
}

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
      logWarnings();
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/is_instance_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      generateBindingsForCoverage('is_instance');
    });

    test('Unrelated classes', () {
      final base = NSObject.castFrom(BaseClass.new1());
      final unrelated = NSObject.castFrom(UnrelatedClass.new1());
      expect(BaseClass.isInstance(base), isTrue);
      expect(BaseClass.isInstance(unrelated), isFalse);
      expect(UnrelatedClass.isInstance(base), isFalse);
      expect(UnrelatedClass.isInstance(unrelated), isTrue);
    });

    test('Base class vs child class', () {
      final base = NSObject.castFrom(BaseClass.new1());
      final child = NSObject.castFrom(ChildClass.new1());
      expect(BaseClass.isInstance(base), isTrue);
      expect(BaseClass.isInstance(child), isTrue);
      expect(ChildClass.isInstance(base), isFalse);
      expect(ChildClass.isInstance(child), isTrue);
    });
  });
}

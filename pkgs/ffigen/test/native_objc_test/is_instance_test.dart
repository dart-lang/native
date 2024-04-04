// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.

@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'is_instance_bindings.dart';
import 'util.dart';

void main() {
  late IsInstanceTestObjCLibrary lib;

  group('isInstance', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/is_instance_test.dylib');
      verifySetupFile(dylib);
      lib = IsInstanceTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
      generateBindingsForCoverage('is_instance');
    });

    test('Unrelated classes', () {
      final base = NSObject.castFrom(lib, BaseClass.new1(lib));
      final unrelated = NSObject.castFrom(lib, UnrelatedClass.new1(lib));
      expect(BaseClass.isInstance(lib, base), isTrue);
      expect(BaseClass.isInstance(lib, unrelated), isFalse);
      expect(UnrelatedClass.isInstance(lib, base), isFalse);
      expect(UnrelatedClass.isInstance(lib, unrelated), isTrue);
    });

    test('Base class vs child class', () {
      final base = NSObject.castFrom(lib, BaseClass.new1(lib));
      final child = NSObject.castFrom(lib, ChildClass.new1(lib));
      expect(BaseClass.isInstance(lib, base), isTrue);
      expect(BaseClass.isInstance(lib, child), isTrue);
      expect(ChildClass.isInstance(lib, base), isFalse);
      expect(ChildClass.isInstance(lib, child), isTrue);
    });
  });
}

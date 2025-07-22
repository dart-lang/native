// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
// Regression tests for https://github.com/dart-lang/ffigen/issues/486.
import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import '../test_utils.dart';
import 'inherited_instancetype_bindings.dart';
import 'util.dart';

void main() {
  group('inheritedInstancetype', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open(
        path.join(
          packagePathForTests,
          '..',
          'objective_c',
          'test',
          'objective_c.dylib',
        ),
      );
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
      generateBindingsForCoverage('inherited_instancetype');
    });

    test('Ordinary init method', () {
      final ChildClass child = ChildClass.alloc().init();
      expect(child.field, 123);
      final ChildClass sameChild = child.getSelf();
      sameChild.field = 456;
      expect(child.field, 456);
    });

    test('Custom create method', () {
      final ChildClass child = ChildClass.create();
      expect(child.field, 123);
      final ChildClass sameChild = child.getSelf();
      sameChild.field = 456;
      expect(child.field, 456);
    });

    test('Polymorphism', () {
      final ChildClass child = ChildClass.alloc().init();
      final BaseClass base = child;

      // Calling base.getSelf() goes through BaseClass.getSelf on the Dart side,
      // but is dynamically dispatched to the ObjC method ChildClass.getSelf. So
      // the Dart wrapper object is a BaseClass, but the underlying ObjC object
      // is a ChildClass.
      final BaseClass sameChild = base.getSelf();
      expect(sameChild, isA<BaseClass>());
      expect(ChildClass.isInstance(sameChild), isTrue);
    });
  });
}

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
import 'native_objc_test_bindings.dart';
import 'util.dart';

void main() {
  group('native_objc_test', () {
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
      generateBindingsForCoverage('native_objc');
    });

    test('Basic types', () {
      final foo = Foo();
      final obj = NSObject();

      foo.intVal = 123;
      expect(foo.intVal, 123);

      foo.boolVal = true;
      expect(foo.boolVal, true);

      foo.idVal = obj;
      expect(foo.idVal, obj);

      foo.selVal = Pointer<ObjCSelector>.fromAddress(456);
      expect(foo.selVal.address, 456);

      foo.classVal = obj;
      expect(foo.classVal, obj);
    });

    test('Interface basics, with Foo', () {
      final foo1 = Foo.makeFoo(3.14159);
      final foo2 = Foo.makeFoo(2.71828);

      expect(foo1.intVal, 3);
      expect(foo2.intVal, 2);

      expect(foo1.multiply(false, withOtherFoo: foo2), 8);
      expect(foo1.multiply(true, withOtherFoo: foo2), 6);

      foo1.intVal = 100;
      expect(foo1.multiply(false, withOtherFoo: foo2), 8);
      expect(foo1.multiply(true, withOtherFoo: foo2), 200);

      foo2.setDoubleVal(1.61803);
      expect(foo1.multiply(false, withOtherFoo: foo2), 5);
      expect(foo1.multiply(true, withOtherFoo: foo2), 200);
    });
  });
}

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
import 'cast_bindings.dart';
import 'util.dart';

void main() {
  Castaway? testInstance;

  group('cast', () {
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
      testInstance = Castaway();
      generateBindingsForCoverage('cast');
    });

    test('as', () {
      final fromCast = Castaway.as(testInstance!.meAsNSObject());
      expect(fromCast, testInstance!);
    });

    test('fromPointer', () {
      final meAsInt = testInstance!.meAsInt();
      final fromCast = Castaway.fromPointer(
        Pointer<ObjCObjectImpl>.fromAddress(meAsInt),
      );
      expect(fromCast, testInstance!);
    });

    test('pointers are equal', () {
      final meAsInt = testInstance!.meAsInt();
      expect(testInstance!.ref.pointer.address, meAsInt);
    });

    test('equality equals', () {
      final meAsInt = testInstance!.meAsInt();
      final fromCast = Castaway.fromPointer(
        Pointer<ObjCObjectImpl>.fromAddress(meAsInt),
      );
      expect(fromCast, testInstance!);
    });

    test('equality not equals', () {
      final meAsInt = testInstance!.meAsInt();
      final fromCast = Castaway.fromPointer(
        Pointer<ObjCObjectImpl>.fromAddress(meAsInt),
      );
      expect(fromCast, isNot(equals(NSObject())));
    });
  });
}

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
import 'cast_bindings.dart';
import 'util.dart';

void main() {
  Castaway? testInstance;

  group('cast', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/cast_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      testInstance = Castaway.new1();
      generateBindingsForCoverage('cast');
    });

    test('castFrom', () {
      final fromCast = Castaway.castFrom(testInstance!.meAsNSObject());
      expect(fromCast, testInstance!);
    });

    test('castFromPointer', () {
      final meAsInt = testInstance!.meAsInt();
      final fromCast =
          Castaway.castFromPointer(Pointer<ObjCObject>.fromAddress(meAsInt));
      expect(fromCast, testInstance!);
    });

    test('pointers are equal', () {
      final meAsInt = testInstance!.meAsInt();
      expect(testInstance!.pointer.address, meAsInt);
    });

    test('equality equals', () {
      final meAsInt = testInstance!.meAsInt();
      final fromCast =
          Castaway.castFromPointer(Pointer<ObjCObject>.fromAddress(meAsInt));
      expect(fromCast, testInstance!);
    });

    test('equality not equals', () {
      final meAsInt = testInstance!.meAsInt();
      final fromCast =
          Castaway.castFromPointer(Pointer<ObjCObject>.fromAddress(meAsInt));
      expect(fromCast, isNot(equals(NSObject.new1())));
    });
  });
}

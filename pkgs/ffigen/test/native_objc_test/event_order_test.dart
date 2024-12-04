// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';
import '../test_utils.dart';
import 'event_order_bindings.dart';
import 'util.dart';

void main() {
  group('event ordering', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/objc_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      generateBindingsForCoverage('event_order');
    });

    test('Many listener calls with different signatures', () async {
      final result = <int>[];

      EventOrderTest.countTo1000OnNewThread___________________(
        ObjCBlock_ffiVoid_Int32_Int8.listener((x, _) => result.add(x)),
        ObjCBlock_ffiVoid_Int32_Int16.listener((x, _) => result.add(x)),
        ObjCBlock_ffiVoid_Int32_Int32.listener((x, _) => result.add(x)),
        ObjCBlock_ffiVoid_Int32_Int64.listener((x, _) => result.add(x)),
        ObjCBlock_ffiVoid_Int32_Uint8.listener((x, _) => result.add(x)),
        ObjCBlock_ffiVoid_Int32_Uint16.listener((x, _) => result.add(x)),
        ObjCBlock_ffiVoid_Int32_Uint32.listener((x, _) => result.add(x)),
        ObjCBlock_ffiVoid_Int32_Uint64.listener((x, _) => result.add(x)),
        ObjCBlock_ffiVoid_Int32_ffiDouble.listener((x, _) => result.add(x)),
        ObjCBlock_ffiVoid_Int32_ffiFloat.listener((x, _) => result.add(x)),
      );

      while (result.length < 1000) {
        await Future.delayed(Duration(milliseconds: 10));
      }
      expect(result, [ for (int i = 1; i <= 1000; ++i) i ]);
    });
  });
}

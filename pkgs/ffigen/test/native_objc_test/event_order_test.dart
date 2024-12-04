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

      final protocol = EventOrderProtocol.implementAsListener(
        method1_y_: (x, _) => result.add(x),
        method2_y_: (x, _) => result.add(x),
        method3_y_: (x, _) => result.add(x),
        method4_y_: (x, _) => result.add(x),
        method5_y_: (x, _) => result.add(x),
        method6_y_: (x, _) => result.add(x),
        method7_y_: (x, _) => result.add(x),
        method8_y_: (x, _) => result.add(x),
        method9_y_: (x, _) => result.add(x),
        method10_y_: (x, _) => result.add(x),
      );

      EventOrderTest.countTo1000OnNewThread_(protocol);

      while (result.length < 1000) {
        await Future.delayed(Duration(milliseconds: 10));
      }
      expect(result, [ for (int i = 1; i <= 1000; ++i) i ]);
    });
  });
}

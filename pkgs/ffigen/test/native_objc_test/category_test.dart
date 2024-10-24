// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'category_bindings.dart';
import 'util.dart';

void main() {
  late Thing testInstance;

  group('categories', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/objc_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      testInstance = Thing.new1();
      generateBindingsForCoverage('category');
    });

    test('Category method', () {
      expect(testInstance.add_Y_(1000, 234), 1234);
      expect(testInstance.sub_Y_(1234, 1000), 234);
      expect(testInstance.mul_Y_(1234, 1000), 1234000);
      expect(testInstance.someProperty, 456);
    });
  });
}

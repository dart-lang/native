// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'bad_method_test_bindings.dart';
import 'package:path/path.dart' as path;
import 'util.dart';

void main() {
  group('bad_method_test', () {
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
      generateBindingsForCoverage('bad_method');
    });

    test("Test incomplete struct methods that weren't skipped", () {
      final obj = BadMethodTestObject();
      final structPtr = obj.incompletePointerReturn();
      expect(structPtr.address, 1234);
      expect(obj.incompletePointerParam(structPtr), 1234);
    });

    test("Test bit field methods that weren't skipped", () {
      final obj = BadMethodTestObject();
      final bitFieldPtr = obj.bitFieldPointerReturn();
      expect(bitFieldPtr.address, 5678);
      expect(obj.bitFieldPointerParam(bitFieldPtr), 5678);
    });
  });
}

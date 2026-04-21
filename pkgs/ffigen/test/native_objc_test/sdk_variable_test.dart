// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import '../test_utils.dart';
import 'util.dart';

void main() {
  group('SDK variable', () {
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

      // TODO(https://github.com/dart-lang/native/issues/3318): Remove custom
      // verifier.
      verifyBindings('sdk_variable', (expected, actual) {
        return actual.contains('extension type NSColorPicker.') &&
            actual.contains('extension type UIPickerView.') &&
            actual.contains('extension type NSTextList.');
      });
    });

    test('dummy', () {});
  });
}

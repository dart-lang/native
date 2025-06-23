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
    late String bindings;

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
      generateBindingsForCoverage('rename');
      bindings = File(
        path.join(
          packagePathForTests,
          'test',
          'native_objc_test',
          'sdk_variable_bindings.dart',
        ),
      ).readAsStringSync();
    });

    test('XCODE', () {
      expect(bindings, contains('class NSColorPicker '));
    });

    test('IOS_SDK', () {
      expect(bindings, contains('class UIPickerView '));
    });

    test('MACOS_SDK', () {
      expect(bindings, contains('class NSTextList '));
    });
  });
}

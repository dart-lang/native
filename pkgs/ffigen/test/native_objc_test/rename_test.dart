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
import 'rename_bindings.dart';
import 'util.dart';

void main() {
  group('rename_test', () {
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
    });

    test('Renamed class', () {
      final renamed = Renamed();

      renamed.property = 123;
      expect(renamed.property, 123);
    });

    test('Method with the same name as a Dart built in method', () {
      final renamed = Renamed();

      renamed.property = 123;
      expect(renamed.toString(), "Instance of 'Renamed'");
      expect(renamed.toString$1().toDartString(), "123");
    });

    test('Method with the same name as a type', () {
      final renamed = Renamed();

      expect(renamed.CollidingStructName$1(), 456);
    });

    test('Renamed method', () {
      final renamed = Renamed();

      expect(renamed.fooBarBaz(123, y: 456), 579);
    });

    test('Renamed property', () {
      final renamed = Renamed();

      renamed.reProp = 2468;
      expect(renamed.reProp, 2468);
    });
  });
}

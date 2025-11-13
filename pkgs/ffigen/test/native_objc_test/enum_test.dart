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
import 'enum_bindings.dart';
import 'util.dart';

void main() {
  group('enum', () {
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
      generateBindingsForCoverage('enum');
    });

    test('NS_ENUM generates a Dart enum', () {
      expect(Fruit.FruitOrange.value, 2);
      expect(Fruit.fromValue(3), Fruit.FruitPear);
    });

    test('NS_OPTIONS generates Dart int constants', () {
      expect(CoffeeOptions.CoffeeOptionsSugar, 2);
      expect(
        CoffeeOptions.CoffeeOptionsMilk | CoffeeOptions.CoffeeOptionsIced,
        5,
      );
    });

    test('Multi def regression test', () {
      // Regression test for https://github.com/dart-lang/native/issues/2782
      final bindings = File(
        path.join(
          packagePathForTests,
          'test',
          'native_objc_test',
          'enum_bindings.dart',
        ),
      ).readAsStringSync();

      expect(bindings, isNot(contains('UnnamedEnumValue\$1')));
      expect(bindings, isNot(contains('SOME_MACRO\$1')));
    });
    
    test('Imported enum', () {
      // Regression test for https://github.com/dart-lang/native/issues/2761
      expect(
        EnumTestInterface.useImportedNSEnum(
          NSQualityOfService.NSQualityOfServiceUtility,
        ),
        17,
      );
      expect(
        EnumTestInterface.useImportedNSOptions(
          NSOrderedCollectionDifferenceCalculationOptions
              .NSOrderedCollectionDifferenceCalculationOmitInsertedObjects,
        ),
        1,
      );
    });
  });
}

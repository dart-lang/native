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
  });
}

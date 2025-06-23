// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout(const Duration(minutes: 2))

import 'dart:ffi';

import 'package:test/test.dart';

import 'classes_bindings.dart';
import 'util.dart';

void main() {
  group('Classes', () {
    setUpAll(() async {
      final gen = TestGenerator('classes');
      await gen.generateAndVerifyBindings();
      DynamicLibrary.open(gen.dylibFile);
    });

    test('method invocation', () {
      final testClass = TestClassWrapper.create();
      final testOtherClass = testClass.myMethod();
      expect(testOtherClass.times10WithX_(123), 1230);
    });
  });
}

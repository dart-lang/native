// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout(Duration(minutes: 2))
library;

import 'dart:ffi';

import 'package:test/test.dart';

import 'regress_2871_bindings.dart';
import 'util.dart';

void main() {
  group('Regression test for #2871', () {
    setUpAll(() async {
      final gen = TestGenerator('regress_2871');
      await gen.generateAndVerifyBindings();
      DynamicLibrary.open(gen.dylibFile);
    });

    test('method invocation', () {
      final obj = TestFuncs.echoObject();
      expect(obj, isNotNull);
      expect(TestEmptyClass.isA(obj!), isTrue);
    });
  });
}

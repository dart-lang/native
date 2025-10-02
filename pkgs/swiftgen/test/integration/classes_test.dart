// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout(Duration(minutes: 2))
library;

import 'dart:ffi';

import 'package:test/test.dart';

import 'classes_bindings.dart';
import 'util.dart';

void main([List<String> args = const []]) {
  group('Classes', () {
    setUpAll(() async {
      final gen = TestGenerator('classes', args);
      await gen.generateAndVerifyBindings();
      DynamicLibrary.open(gen.dylibFile);

      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open(objCTestDylib);
    });

    test('method invocation', () {
      final testClass = TestClassWrapper.create();
      final testOtherClass = testClass.myMethod();
      expect(testOtherClass.times10WithX(123), 1230);
    });
  });
}

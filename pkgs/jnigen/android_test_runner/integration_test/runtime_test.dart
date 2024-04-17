// Generated file. Do not edit or check-in to version control.

// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:flutter_test/flutter_test.dart";

import "../../test/jackson_core_test/runtime_test_registrant.dart"
    as jackson_core_test;
import "../../test/simple_package_test/runtime_test_registrant.dart"
    as simple_package_test;
import "../../test/kotlin_test/runtime_test_registrant.dart" as kotlin_test;

typedef TestCaseCallback = void Function();

void test(String description, TestCaseCallback testCase) {
  testWidgets(description, (widgetTester) async => testCase());
}

void main() {
  jackson_core_test.registerTests("jackson_core_test", test);
  simple_package_test.registerTests("simple_package_test", test);
  kotlin_test.registerTests("kotlin_test", test);
}

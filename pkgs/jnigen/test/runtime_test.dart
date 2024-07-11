// Generated file. Do not edit or check-in to version control.

// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'jackson_core_test/runtime_test_registrant.dart' as jackson_core_test;
import 'kotlin_test/runtime_test_registrant.dart' as kotlin_test;
import 'simple_package_test/runtime_test_registrant.dart'
    as simple_package_test;
import 'test_util/bindings_test_setup.dart' as setup;

void main() {
  setUpAll(setup.bindingsTestSetup);
  jackson_core_test.registerTests('jackson_core_test_dart_only', test);
  simple_package_test.registerTests('simple_package_test_dart_only', test);
  kotlin_test.registerTests('kotlin_test_c_based', test);
  tearDownAll(setup.bindingsTestTeardown);
}

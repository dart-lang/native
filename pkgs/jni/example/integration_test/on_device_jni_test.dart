// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import '../../test/global_env_test.dart' as global_env_test;
import '../../test/exception_test.dart' as exception_test;
import '../../test/jobject_test.dart' as jobject_test;
import '../../test/jarray_test.dart' as jarray_test;
import '../../test/type_test.dart' as type_test;

void integrationTestRunner(String description, void Function() testCallback) {
  testWidgets(description, (widgetTester) async => testCallback());
}

void main() {
  final testSuites = [
    global_env_test.run,
    exception_test.run,
    jobject_test.run,
    jarray_test.run,
    type_test.run,
  ];
  for (var testSuite in testSuites) {
    testSuite(testRunner: integrationTestRunner);
  }
}

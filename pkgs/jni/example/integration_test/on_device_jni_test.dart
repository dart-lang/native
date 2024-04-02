// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import '../../test/global_env_test.dart' as global_env_test;
import '../../test/exception_test.dart' as exception_test;
import '../../test/jlist_test.dart' as jlist_test;
import '../../test/jmap_test.dart' as jmap_test;
import '../../test/jobject_test.dart' as jobject_test;
import '../../test/jstring_test.dart' as jstring_test;
import '../../test/jset_test.dart' as jset_test;
import '../../test/jarray_test.dart' as jarray_test;
import '../../test/boxed_test.dart' as boxed_test;
import '../../test/type_test.dart' as type_test;
import '../../test/load_test.dart' as load_test;
import '../../test/isolate_test.dart' as isolate_test;

void integrationTestRunner(String description, void Function() testCallback,
    {Object? skip}) {
  testWidgets(description, (_) async => testCallback(),
      skip: skip != null && skip != false);
}

void main() {
  final testSuites = [
    global_env_test.run,
    exception_test.run,
    jlist_test.run,
    jmap_test.run,
    jobject_test.run,
    jstring_test.run,
    jset_test.run,
    jarray_test.run,
    boxed_test.run,
    type_test.run,
    load_test.run,
    isolate_test.run,
  ];
  for (var testSuite in testSuites) {
    testSuite(testRunner: integrationTestRunner);
  }
}

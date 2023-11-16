// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// These definitions could be in `test_util` but these are imported by android
// integration tests, and we test_util imports several parts of package:jnigen.

typedef TestCaseCallback = void Function();
typedef TestRunnerCallback = void Function(
  String description,
  TestCaseCallback test,
);

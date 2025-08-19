// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_dynamic_linking_example/add.dart';
import 'package:test/test.dart';

void main() {
  test(
    'invoke native function',
    skip:
        (Platform.isMacOS || Platform.isWindows) &&
            Platform.environment['GITHUB_ACTIONS'] != null
        ? 'https://github.com/dart-lang/native/issues/2501'
        : false,
    () {
      expect(add(24, 18), 42);
    },
  );
}

// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=76

// snippet-start
import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

void main() {
  test('test my build hook', () async {
    await testCodeBuildHook(
      mainMethod: (args) {},
      check: (input, output) {},
    );
  });
}

// snippet-end

// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=76
// ignore_for_file: experimental_member_use

// snippet-start
import 'package:hooks/src/test.dart';
import 'package:test/test.dart';

void main() {
  test('test my doctor hook', () async {
    await testDoctorHook(mainMethod: (args) {}, check: (input, output) {});
  });
}

// snippet-end

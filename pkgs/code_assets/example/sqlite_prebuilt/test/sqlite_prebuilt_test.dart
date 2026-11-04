// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'package:hooks/hooks.dart';
import 'package:sqlite_prebuilt/sqlite_prebuilt.dart';
import 'package:test/test.dart';

import '../hook/doctor.dart' as doctor_hook;

void main() {
  test('version', () {
    expect(version, isNotEmpty);
    expect(version, startsWith('3.'));
  });

  test('doctor hook', () async {
    await testDoctorHook(
      mainMethod: doctor_hook.main,
      check: (input, output) {
        expect(output.validations, hasLength(1));
        expect(
          output.validations.single.title,
          'SQLite3 (package:sqlite_prebuilt)',
        );
      },
    );
  });
}

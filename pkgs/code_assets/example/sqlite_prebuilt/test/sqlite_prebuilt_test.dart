// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
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
    // ignore: experimental_member_use
    await testDoctorHook(
      mainMethod: doctor_hook.main,
      extensions: [
        // ignore: experimental_member_use
        DoctorCodeAssetExtension(
          configs: [
            // ignore: experimental_member_use
            DoctorCodeConfig(
              targetOS: OS.current,
              targetArchitecture: Architecture.current,
            ),
          ],
        ),
      ],
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

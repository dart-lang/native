// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

import '../hook/build.dart' as build_hook;
import '../hook/doctor.dart' as doctor_hook;

void main() {
  test('build hook', () async {
    await testBuildHook(
      mainMethod: build_hook.main,
      extensions: [DataAssetsExtension()],
      check: (input, output) {
        expect(output.assets.data, hasLength(1));
        expect(
          output.assets.data.single.id,
          'package:cli_tool/git_version.txt',
        );
      },
    );
  });

  test('doctor hook', () async {
    await testDoctorHook(
      mainMethod: doctor_hook.main,
      check: (input, output) {
        expect(output.validations, hasLength(1));
        final validation = output.validations.single;
        expect(validation.title, 'Git (package:cli_tool)');
        expect(validation.type, DoctorValidationType.success);
        expect(validation.messages.single.message, startsWith('Found git at '));
      },
    );
  });
}

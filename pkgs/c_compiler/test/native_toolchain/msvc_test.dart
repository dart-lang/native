// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('windows')
library;

import 'dart:io';

import 'package:c_compiler/src/native_toolchain/msvc.dart';
import 'package:c_compiler/src/utils/env_from_bat.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isWindows) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  test('vswhere', () async {
    final instances = await vswhere.defaultResolver!.resolve(logger: logger);
    expect(instances.isNotEmpty, true);
  });

  test('visualStudio', () async {
    final instances =
        await visualStudio.defaultResolver!.resolve(logger: logger);
    expect(instances.isNotEmpty, true);
  });

  test('msvc', () async {
    final instances = await msvc.defaultResolver!.resolve(logger: logger);
    expect(instances.isNotEmpty, true);
  });

  test('cl', () async {
    final instances = await cl.defaultResolver!.resolve(logger: logger);
    expect(instances.isNotEmpty, true);
  });

  test('vcvars32', () async {
    final instances = await vcvars32.defaultResolver!.resolve(logger: logger);
    expect(instances.isNotEmpty, true);
    final instance = instances.first;
    final env = await envFromBat(instance.uri);
    expect(env['INCLUDE'] != null, true);
    expect(env['WindowsSdkDir'] != null, true); // stdio.h
  });

  test('vcvars64', () async {
    final instances = await vcvars64.defaultResolver!.resolve(logger: logger);
    expect(instances.isNotEmpty, true);
    final instance = instances.first;
    final env = await envFromBat(instance.uri);
    expect(env['INCLUDE'] != null, true);
    expect(env['WindowsSdkDir'] != null, true); // stdio.h
  });

  test('vcvarsall', () async {
    final instances = await vcvarsall.defaultResolver!.resolve(logger: logger);
    expect(instances.isNotEmpty, true);
    final instance = instances.first;
    final env = await envFromBat(
      instance.uri,
      arguments: [
        'x64',
        'uwp',
        '10.0',
      ],
    );
    expect(env['INCLUDE'] != null, true);
    expect(env['WindowsSdkDir'] != null, true); // stdio.h
  });

  test('vsDevCmd', () async {
    final instances = await vsDevCmd.defaultResolver!.resolve(logger: logger);
    expect(instances.isNotEmpty, true);
    final instance = instances.first;
    final env = await envFromBat(instance.uri);
    expect(env['INCLUDE'] != null, true);
    expect(env['WindowsSdkDir'] != null, true); // stdio.h
  });
}

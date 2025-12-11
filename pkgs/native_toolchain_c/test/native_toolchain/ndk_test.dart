// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_toolchain_c/src/native_toolchain/android_ndk.dart';
import 'package:native_toolchain_c/src/tool/tool_requirement.dart';
import 'package:native_toolchain_c/src/tool/tool_resolver.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../helpers.dart';

void main() {
  test('NDK smoke test', () async {
    final requirement = RequireAll([
      ToolRequirement(androidNdk),
      ToolRequirement(androidNdkClang),
      ToolRequirement(androidNdkLlvmAr),
      ToolRequirement(androidNdkLld),
    ]);
    final resolved = await androidNdk.defaultResolver!.resolve(systemContext);
    printOnFailure(resolved.toString());
    final satisfied = requirement.satisfy(resolved);
    expect(satisfied?.length, 4);
  });

  test('discovers NDK in ANDROID_HOME', () async {
    await d.dir('fake_android', [
      d.dir('ndk', [d.dir('1.3.37')]),
    ]).create();

    final resolved = await androidNdk.defaultResolver!.resolve(
      ToolResolvingContext(
        logger: logger,
        environment: {'ANDROID_HOME': d.path('fake_android')},
      ),
    );
    resolved.retainWhere((e) => e.tool.name == androidNdk.name);

    expect(
      resolved.map((e) => e.uri.toFilePath()),
      contains(
        Directory(
          d.sandbox,
        ).uri.resolve('fake_android/ndk/1.3.37/').toFilePath(),
      ),
    );
  });

  test('discovers NDK in ANDROID_NDK_HOME', () async {
    await d.dir('weird', [
      d.dir('ndk', [d.dir('directory')]),
    ]).create();

    final resolved = await androidNdk.defaultResolver!.resolve(
      ToolResolvingContext(
        logger: logger,
        environment: {'ANDROID_NDK_HOME': d.path('weird/ndk/directory')},
      ),
    );
    resolved.retainWhere((e) => e.tool.name == androidNdk.name);

    expect(
      resolved.map((e) => e.uri.toFilePath()),
      contains(
        Directory(d.sandbox).uri.resolve('weird/ndk/directory/').toFilePath(),
      ),
    );
  });
}

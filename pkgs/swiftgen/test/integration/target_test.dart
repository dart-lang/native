// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:swiftgen/swiftgen.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  test('Custom target is propagated to Swift2ObjCGenerator', () async {
    final [host, x64, arm] = await Future.wait([
      Target.host(),
      Target.macOSX64Latest(),
      Target.macOSArm64Latest(),
    ]);

    final hostArch = host.triple.split('-').first;

    Target compileTarget;

    // We will aim to generate bindings for a different architecture to ensure
    // that `Swift2ObjCGenerator` doesn't fallback to `host` architecture.
    if (x64.triple.startsWith(hostArch)) {
      compileTarget = arm;
    } else {
      compileTarget = x64;
    }

    final gen = TestGenerator('target');
    await gen.generateAndVerifyBindings(compileTarget);

    expect(
      File(gen.dylibFile).existsSync(),
      isTrue,
      reason: 'Dylib should be generated',
    );

    // Verify the architecture of the generated dylib
    final result = await Process.run('lipo', ['-info', gen.dylibFile]);

    // `lipo -info` outputs the architecture along with filename
    // hence we extract only the architecture rather than matching
    // on the entire output, because the filename can also contain
    // arm64 or x86_64.
    final compiledArch = result.stdout.toString().split(':').last;
    if (compileTarget.triple.startsWith('arm64')) {
      expect(
        compiledArch,
        equalsIgnoringWhitespace('arm64'),
        reason: 'Dylib should be compiled for arm64',
      );
    } else {
      expect(
        compiledArch,
        equalsIgnoringWhitespace('x86_64'),
        reason: 'Dylib should be compiled for x86_64',
      );
    }
  });
}

// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'dartified_snippets/enums.dart';
import 'dartified_snippets/implement_inline_interface.dart';
import 'dartified_snippets/implement_normal_interface.dart';
import 'dartified_snippets/overloaded_methods.dart';

void main() {
  setUpAll(() {
    final setup = Process.runSync('dart', ['run', 'jni:setup']);
    if (setup.exitCode != 0) {
      throw Exception('Failed to run jni:setup: ${setup.stderr}');
    }

    Jni.spawn(
      dylibDir: 'build/jni_libs',
      classPath: [
        'build/jni_libs/jni.jar',
        'test/dartify_simple_cases/compiled',
      ],
    );
  });

  test('Overloaded Methods and Constructors', () async {
    expect(overloadedMethods(), isTrue);
  });

  test('Implement Inline Interface', () async {
    expect(implementInlineInterface(), isTrue);
  });

  test('Implement Normal Interface', () async {
    expect(implementNormalInterface(), isTrue);
  });

  test('Use Enums', () async {
    expect(useEnums(), isTrue);
  });
}

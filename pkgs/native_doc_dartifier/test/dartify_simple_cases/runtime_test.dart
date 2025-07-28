// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'dartified_snippets/enums.dart';
import 'dartified_snippets/identifiers.dart';
import 'dartified_snippets/implement_inline_interface.dart';
import 'dartified_snippets/implement_normal_interface.dart';
import 'dartified_snippets/inner_class.dart';
import 'dartified_snippets/overloaded_methods.dart';
import 'dartified_snippets/strings.dart';

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

  test('Inner Class Call', () async {
    expect(innerClassCall(), isTrue);
  });

  test('Back and Forth Strings', () async {
    expect(backAndForthStrings(), isTrue);
  });

  test('identifiers has \$ and starts with "_"', () async {
    expect(identifiersSpecialCases(), isTrue);
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

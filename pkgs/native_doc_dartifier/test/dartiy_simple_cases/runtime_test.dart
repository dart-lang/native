// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni/jni.dart';
import 'package:test/test.dart';
import 'dartified_snippets/overloaded_methods.dart';

void main() {
  setUpAll(() {
    Jni.spawn(
      dylibDir: 'build/jni_libs',
      classPath: [
        '../build/jni_libs/jni.jar',
        'test/dartiy_simple_cases/compiled',
      ],
    );
  });

  test('Overloaded Methods and Constructors', () async {
    expect(overloadedMethods(), equals(80));
  });
}

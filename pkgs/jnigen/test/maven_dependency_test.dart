// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/tools/gradle_tools.dart';
import 'package:test/test.dart';

void main() {
  group('MavenDependency', () {
    test('generates javadoc.io URL', () {
      final dependency = MavenDependency.fromString(
        'com.google.code.gson:gson:2.13.1',
      );

      expect(
        dependency.javadocUrl,
        'https://javadoc.io/doc/com.google.code.gson/gson/2.13.1',
      );
    });
  });
}

// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/summary/summary.dart';
import 'package:test/test.dart';

void main() {
  group('getActionableSummaryParseMessage', () {
    test('returns actionable message for unsupported classfile version', () {
      const stderr = '''
Exception in thread "main" java.lang.RuntimeException
Caused by: java.lang.IllegalArgumentException: Unsupported class file major version 66
''';

      final message = getActionableSummaryParseMessage(stderr);

      expect(message, isNotNull);
      expect(message, contains('class file version 66'));
      expect(message, contains('JDK version (11 to 17) (see JNIgen README)'));
      expect(message, contains('javac --release 17'));
    });

    test('returns null for unrelated stderr', () {
      const stderr = 'Not found: [com.github.dart_lang.jnigen.DoesNotExist]';

      final message = getActionableSummaryParseMessage(stderr);

      expect(message, isNull);
    });
  });
}

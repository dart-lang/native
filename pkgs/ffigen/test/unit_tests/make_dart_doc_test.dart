// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/utils.dart';
import 'package:test/test.dart';

void main() {
  group('makeDartDoc', () {
    test('handles standard newlines (\\n)', () {
      expect(makeDartDoc('line1\nline2'), equals('/// line1\n/// line2\n'));
    });

    test('handles carriage return and newline (\\r\\n)', () {
      expect(makeDartDoc('line1\r\nline2'), equals('/// line1\n/// line2\n'));
    });

    test('handles standalone carriage return (\\r)', () {
      expect(makeDartDoc('line1\rline2'), equals('/// line1\n/// line2\n'));
    });

    test('handles mixed line endings', () {
      expect(
        makeDartDoc('line1\r\nline2\rline3\nline4'),
        equals('/// line1\n/// line2\n/// line3\n/// line4\n'),
      );
    });

    test('handles null input', () {
      expect(makeDartDoc(null), equals(''));
    });

    test('handles indent option', () {
      expect(
        makeDartDoc('line1\nline2', indent: '  '),
        equals('  /// line1\n  /// line2\n'),
      );
      expect(
        makeDartDoc('line1\r\nline2', indent: '  '),
        equals('  /// line1\n  /// line2\n'),
      );
      expect(
        makeDartDoc('line1\rline2', indent: '  '),
        equals('  /// line1\n  /// line2\n'),
      );
      expect(makeDartDoc(null, indent: '  '), equals(''));
    });
  });

  group('makeDoc', () {
    test('handles standard newlines (\\n)', () {
      expect(makeDoc('line1\nline2'), equals('// line1\n// line2\n'));
    });

    test('handles carriage return and newline (\\r\\n)', () {
      expect(makeDoc('line1\r\nline2'), equals('// line1\n// line2\n'));
    });

    test('handles standalone carriage return (\\r)', () {
      expect(makeDoc('line1\rline2'), equals('// line1\n// line2\n'));
    });
  });
}

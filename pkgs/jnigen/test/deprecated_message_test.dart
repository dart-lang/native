// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/elements/elements.dart';
import 'package:test/test.dart';

void main() {
  group('JavaDocComment.deprecatedMessage', () {
    test('extracts a single-line message', () {
      final comment = JavaDocComment(
        comment: '@deprecated Use the replacement method instead.',
      );

      expect(
        comment.deprecatedMessage,
        'Use the replacement method instead.',
      );
    });

    test('allows description text before the tag', () {
      final comment = JavaDocComment(
        comment: '''
This method is retained for compatibility.

@deprecated Use the replacement method instead.
''',
      );

      expect(
        comment.deprecatedMessage,
        'Use the replacement method instead.',
      );
    });

    test('extracts a multiline message', () {
      final comment = JavaDocComment(
        comment: '''
@deprecated Use the replacement method instead.
This method will be removed in a future release.
''',
      );

      expect(
        comment.deprecatedMessage,
        'Use the replacement method instead.\n'
        'This method will be removed in a future release.',
      );
    });

    test('stops at the next block tag', () {
      final comment = JavaDocComment(
        comment: '''
@deprecated Use the replacement method instead.
This method will be removed soon.
@return the old result
''',
      );

      expect(
        comment.deprecatedMessage,
        'Use the replacement method instead.\n'
        'This method will be removed soon.',
      );
    });

    test('returns null when the tag is absent', () {
      final comment = JavaDocComment(
        comment: 'This is a regular Javadoc comment.',
      );

      expect(comment.deprecatedMessage, isNull);
    });

    test('returns null when the message is empty', () {
      final comment = JavaDocComment(
        comment: '@deprecated',
      );

      expect(comment.deprecatedMessage, isNull);
    });

    test('escapes apostrophes and dollar signs', () {
      final comment = JavaDocComment(
        comment: r"@deprecated Don't use $oldMethod.",
      );

      expect(
        comment.deprecatedMessage,
        r"Don't use $oldMethod.",
      );
    });

    test('escapes backslashes', () {
      final comment = JavaDocComment(
        comment: r'@deprecated Use C:\temp instead.',
      );

      expect(
        comment.deprecatedMessage,
        r'Use C:\temp instead.',
      );
    });

    test('escapes double quotes', () {
      final comment = JavaDocComment(
        comment: '@deprecated Use "newMethod" instead.',
      );

      expect(
        comment.deprecatedMessage,
        'Use "newMethod" instead.',
      );
    });
  });
}

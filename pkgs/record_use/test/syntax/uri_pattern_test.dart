// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

import '../test_data.dart';

void main() {
  group('Identifier.uri pattern', () {
    test('Recordings.fromJson fails for non-package URI', () {
      final json = recordedUses.toJson();
      // Modify the first recording's identifier URI to be invalid.
      final recordings = json['recordings'] as List;
      final recording = recordings[0] as Map;
      final identifier = recording['identifier'] as Map;
      identifier['uri'] = 'file:///foo.dart'; // Should start with package:

      expect(
        () => Recordings.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Expected a String satisfying ^package:'),
          ),
        ),
      );
    });

    test('RecordedUsages.fromJson fails for non-package URI', () {
      final json = recordedUses.toJson();
      // Modify the first recording's identifier URI to be invalid.
      final recordings = json['recordings'] as List;
      final recording = recordings[0] as Map;
      final identifier = recording['identifier'] as Map;
      identifier['uri'] = 'file:///foo.dart'; // Should start with package:

      expect(
        () => RecordedUsages.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Expected a String satisfying ^package:'),
          ),
        ),
      );
    });

    test('Identifier constructor does not throw (currently)', () {
      // The Identifier class itself doesn't have the regex check in its
      // constructor, only the generated syntax class has it.
      expect(
        () => const Identifier(importUri: 'dart:core', name: 'foo'),
        returnsNormally,
      );
    });
  });
}

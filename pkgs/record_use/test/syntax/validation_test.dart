// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

import '../test_data.dart';

void main() {
  group('Recordings.fromJson validation', () {
    test('Recordings.fromJson fails for invalid JSON', () {
      final json = recordedUses.toJson();
      // Modify the first definition's URI to be an invalid type.
      final definitions = json['definitions'] as List;
      final definition = definitions[0] as Map;
      definition['uri'] = 123; // Should be a string

      expect(
        () => Recordings.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Validation errors for record use file:'),
          ),
        ),
      );
    });
  });
}

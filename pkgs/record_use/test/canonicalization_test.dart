// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use_internal.dart';
import 'package:record_use/src/canonicalization_context.dart';
import 'package:test/test.dart';

void main() {
  group('Canonicalization', () {
    test('canonicalizeConstant deduplicates identical constants', () {
      final context = CanonicalizationContext();
      // We avoid 'const' to ensure we have non-identical objects that are
      // semantically equal, verifying that the canonicalization logic
      // correctly deduplicates them.
      // ignore: prefer_const_constructors
      final c1 = IntConstant(42);
      // ignore: prefer_const_constructors
      final c2 = IntConstant(42);

      expect(identical(c1, c2), isFalse);

      final canonical1 = context.canonicalizeConstant(c1);
      final canonical2 = context.canonicalizeConstant(c2);

      expect(identical(canonical1, canonical2), isTrue);
    });

    test('canonicalizeConstant handles nested constants', () {
      final context = CanonicalizationContext();
      // ignore: prefer_const_constructors
      final list1 = ListConstant([
        // ignore: prefer_const_constructors
        IntConstant(1),
        // ignore: prefer_const_constructors
        IntConstant(2),
      ]);
      // ignore: prefer_const_constructors
      final list2 = ListConstant([
        // ignore: prefer_const_constructors
        IntConstant(1),
        // ignore: prefer_const_constructors
        IntConstant(2),
      ]);

      expect(identical(list1, list2), isFalse);

      final canonical1 = context.canonicalizeConstant(list1) as ListConstant;
      final canonical2 = context.canonicalizeConstant(list2) as ListConstant;

      expect(identical(canonical1, canonical2), isTrue);
      expect(identical(canonical1.value[0], canonical2.value[0]), isTrue);
    });

    test('Recordings.toJson canonicalizes constants across calls', () {
      const definition = Definition('package:a/a.dart', [Name('foo')]);
      const constant = IntConstant(42);

      final recordings = Recordings(
        calls: {
          definition: [
            const CallWithArguments(
              positionalArguments: [constant],
              namedArguments: {},
              loadingUnits: [],
            ),
            const CallWithArguments(
              positionalArguments: [constant],
              namedArguments: {},
              loadingUnits: [],
            ),
          ],
        },
        instances: {},
      );

      final json = recordings.toJson();
      final constants = json['constants'] as List;

      // The constant 42 should only appear once in the constants table.
      expect(constants, hasLength(1));
      expect(constants[0], {'type': 'int', 'value': 42});

      // Both calls should reference the same constant index.
      final uses = json['uses'] as Map;
      final staticCalls = uses['static_calls'] as List;
      final recording = staticCalls[0] as Map;
      final calls = recording['uses'] as List;
      expect((calls[0] as Map)['positional'], [0]);
      expect((calls[1] as Map)['positional'], [0]);
    });
  });
}

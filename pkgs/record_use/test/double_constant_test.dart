// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:record_use/record_use.dart';
import 'package:record_use/src/canonicalization_context.dart';
import 'package:test/test.dart';

void main() {
  group('DoubleConstant', () {
    test('serialization round-trip', () {
      final constants = [
        const DoubleConstant(3.14),
        const DoubleConstant(0.0),
        const DoubleConstant(-0.0),
        const DoubleConstant(double.infinity),
        const DoubleConstant(double.negativeInfinity),
        const DoubleConstant(double.nan),
        const DoubleConstant(1.2345678901234567),
        const DoubleConstant(0.12345678901234567),
        const DoubleConstant(
          0.12345678901234568,
        ), // different by 1 in last digit
        const DoubleConstant(1.1111111111111112),
        const DoubleConstant(0.3333333333333333),
        const DoubleConstant(5e-324), // min positive double
        const DoubleConstant(1.7976931348623157e308), // max double
      ];

      for (final constant in constants) {
        final recordings = Recordings(
          calls: {
            const Method('foo', Library('package:a/a.dart')): [
              CallWithArguments(
                positionalArguments: [constant],
                namedArguments: const {},
                loadingUnit: const LoadingUnit('1'),
              ),
            ],
          },
          instances: const {},
        );

        final json = jsonEncode(recordings.toJson());
        final roundTripped = Recordings.fromJson(
          jsonDecode(json) as Map<String, Object?>,
        );

        final roundTrippedConstant =
            (roundTripped.calls.values.first.first as CallWithArguments)
                    .positionalArguments
                    .first
                as DoubleConstant;

        if (constant.value.isNaN) {
          expect(roundTrippedConstant.value.isNaN, isTrue);
        } else {
          expect(roundTrippedConstant.value, equals(constant.value));
          // Check sign for 0.0 vs -0.0
          expect(
            roundTrippedConstant.value.isNegative,
            equals(constant.value.isNegative),
          );
        }
        expect(roundTrippedConstant, equals(constant));
        expect(roundTripped, equals(recordings));
      }
    });

    test('equality and hashCode', () {
      const c1 = DoubleConstant(3.14);
      const c1b = DoubleConstant(3.14);
      const c2 = DoubleConstant(2.71);
      const z1 = DoubleConstant(0.0);
      const z2 = DoubleConstant(-0.0);
      const inf1 = DoubleConstant(double.infinity);
      const inf2 = DoubleConstant(double.negativeInfinity);
      const nan1 = DoubleConstant(double.nan);
      const nan2 = DoubleConstant(double.nan);

      expect(c1, equals(c1b));
      expect(c1.hashCode, equals(c1b.hashCode));

      expect(c1, isNot(equals(c2)));

      expect(z1, isNot(equals(z2)));
      expect(z1.hashCode, isNot(equals(z2.hashCode)));

      expect(inf1, isNot(equals(inf2)));

      expect(nan1, equals(nan2));
      expect(nan1.hashCode, equals(nan2.hashCode));

      expect(nan1, isNot(equals(c1)));
      expect(nan1, isNot(equals(inf1)));
    });

    test('semantic equality', () {
      const c1 = DoubleConstant(3.14);
      const nan1 = DoubleConstant(double.nan);
      const unsupported = UnsupportedConstant('reason');

      expect(c1.semanticEquals(c1), isTrue);
      expect(nan1.semanticEquals(nan1), isTrue);
      expect(c1.semanticEquals(nan1), isFalse);

      expect(
        c1.semanticEquals(unsupported, allowPromotionOfUnsupported: true),
        isTrue,
      );
      expect(
        nan1.semanticEquals(unsupported, allowPromotionOfUnsupported: true),
        isTrue,
      );
    });

    test('canonicalization', () {
      final context = CanonicalizationContext();
      const c1 = DoubleConstant(3.14);
      const c1b = DoubleConstant(3.14);
      const z1 = DoubleConstant(0.0);
      const z2 = DoubleConstant(-0.0);
      const nan1 = DoubleConstant(double.nan);
      const nan2 = DoubleConstant(double.nan);

      expect(
        identical(
          context.canonicalizeConstant(c1),
          context.canonicalizeConstant(c1b),
        ),
        isTrue,
      );
      expect(
        identical(
          context.canonicalizeConstant(z1),
          context.canonicalizeConstant(z2),
        ),
        isFalse,
      );
      expect(
        identical(
          context.canonicalizeConstant(nan1),
          context.canonicalizeConstant(nan2),
        ),
        isTrue,
      );
    });
  });
}

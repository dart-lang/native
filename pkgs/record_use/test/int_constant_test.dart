// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:record_use/record_use.dart';
import 'package:test/test.dart';

void main() {
  group('IntConstant', () {
    test('serialization round-trip', () {
      final constants = [
        const IntConstant(0),
        const IntConstant(1),
        const IntConstant(-1),
        const IntConstant(42),
        const IntConstant(-42),
        // 53-bit limit (max precise integer in 64-bit float)
        const IntConstant(9007199254740991), // 2^53 - 1
        const IntConstant(9007199254740992), // 2^53
        const IntConstant(9007199254740993), // 2^53 + 1
        // 64-bit signed limits
        const IntConstant(9223372036854775807), // 2^63 - 1
        const IntConstant(-9223372036854775808), // -2^63
        // Interesting bit patterns
        const IntConstant(0xAAAAAAAAAAAAAAAA),
        const IntConstant(0x5555555555555555),
        const IntConstant(0x7FFFFFFFFFFFFFFF),
        const IntConstant(0x8000000000000000),
        const IntConstant(0xFF00FF00FF00FF00),
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
                as IntConstant;

        expect(roundTrippedConstant.value, equals(constant.value));
        expect(roundTrippedConstant, equals(constant));
        expect(roundTripped, equals(recordings));
      }
    });
  });
}

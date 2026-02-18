// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

void main() {
  test('MaybeConstant arguments in JSON', () {
    const json = {
      'metadata': {'version': '1.0.0', 'comment': 'test'},
      'constants': [
        {'type': 'int', 'value': 42},
        {'type': 'unsupported', 'message': 'Record'},
      ],
      'definitions': [
        {
          'uri': 'package:a/a.dart',
          'path': [
            {'name': 'foo'},
          ],
        },
      ],
      'recordings': [
        {
          'definition_index': 0,
          'calls': [
            {
              'type': 'with_arguments',
              'loading_unit': '1',
              'positional': [0, 1, null],
              'named': {'a': 0, 'b': 1, 'c': null},
            },
          ],
        },
      ],
    };

    final recordings = Recordings.fromJson(json);
    const definition = Definition('package:a/a.dart', [Name('foo')]);
    final calls = recordings.calls[definition]!;
    final call = calls[0] as CallWithArguments;

    expect(call.positionalArguments, hasLength(3));
    expect(call.positionalArguments[0], const IntConstant(42));
    expect(call.positionalArguments[1], const UnsupportedConstant('Record'));
    expect(call.positionalArguments[2], const NonConstant());

    expect(call.namedArguments, hasLength(3));
    expect(call.namedArguments['a'], const IntConstant(42));
    expect(call.namedArguments['b'], const UnsupportedConstant('Record'));
    expect(call.namedArguments['c'], const NonConstant());
  });

  test('MaybeConstant serialization round-trip', () {
    const definition = Definition('package:a/a.dart', [Name('foo')]);
    final recordings = Recordings(
      metadata: Metadata(version: version, comment: 'test'),
      calls: {
        definition: [
          const CallWithArguments(
            positionalArguments: [
              IntConstant(42),
              UnsupportedConstant('Record'),
              NonConstant(),
            ],
            namedArguments: {
              'a': IntConstant(42),
              'b': UnsupportedConstant('Record'),
              'c': NonConstant(),
            },
            loadingUnit: '1',
          ),
        ],
      },
      instances: {},
    );

    final json = recordings.toJson();
    final roundTripped = Recordings.fromJson(json);

    expect(roundTripped, equals(recordings));

    // Verify JSON structure specifically for named nulls
    final recordingsJson = json['recordings'] as List;
    final recording = recordingsJson[0] as Map;
    final call = (recording['calls'] as List)[0] as Map;
    final named = call['named'] as Map;
    expect(named.containsKey('c'), isTrue);
    expect(named['c'], isNull);
  });

  test('allowPromotionOfUnsupported semantic equality', () {
    const definition = Definition('package:a/a.dart', [Name('foo')]);

    final actualRecordings = Recordings(
      metadata: Metadata(version: version, comment: 'actual'),
      calls: {
        definition: [
          const CallWithArguments(
            positionalArguments: [IntConstant(42)],
            namedArguments: {'a': StringConstant('bar')},
            loadingUnit: '1',
          ),
        ],
      },
      instances: {},
    );

    final expectedRecordings = Recordings(
      metadata: Metadata(version: version, comment: 'expected'),
      calls: {
        definition: [
          const CallWithArguments(
            positionalArguments: [UnsupportedConstant('Record')],
            namedArguments: {'a': UnsupportedConstant('Record')},
            loadingUnit: '1',
          ),
        ],
      },
      instances: {},
    );

    // Should not match by default.
    expect(
      actualRecordings.semanticEquals(
        expectedRecordings,
        allowMetadataMismatch: true,
      ),
      isFalse,
    );

    // Should match when promotion is allowed.
    expect(
      actualRecordings.semanticEquals(
        expectedRecordings,
        allowMetadataMismatch: true,
        allowPromotionOfUnsupported: true,
      ),
      isTrue,
    );

    // Verify it doesn't work the other way around (actual is less specific).
    expect(
      expectedRecordings.semanticEquals(
        actualRecordings,
        allowMetadataMismatch: true,
        allowPromotionOfUnsupported: true,
      ),
      isFalse,
    );
  });
}

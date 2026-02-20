// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

const loadingUnit1 = LoadingUnit('1');

void main() {
  test('Call with receiver in JSON', () {
    const json = {
      'metadata': {'version': '1.0.0', 'comment': 'test'},
      'constants': [
        {'type': 'string', 'value': 'receiver'},
        {'type': 'int', 'value': 42},
      ],
      'loading_units': [
        {'name': '1'},
      ],
      'definitions': [
        {
          'uri': 'package:a/a.dart',
          'path': [
            {'name': 'foo'},
          ],
        },
      ],
      'uses': {
        'static_calls': [
          {
            'definition_index': 0,
            'uses': [
              {
                'type': 'with_arguments',
                'loading_unit_indices': [0],
                'receiver': 0,
                'positional': [1],
              },
            ],
          },
        ],
      },
    };

    final recordings = Recordings.fromJson(json);
    const definition = Definition('package:a/a.dart', [Name('foo')]);
    final calls = recordings.calls[definition]!;
    final call = calls[0] as CallWithArguments;

    expect(call.receiver, const StringConstant('receiver'));
    expect(call.positionalArguments[0], const IntConstant(42));
  });

  test('Call with receiver serialization round-trip', () {
    const definition = Definition('package:a/a.dart', [Name('foo')]);
    final recordings = Recordings(
      metadata: Metadata(version: version, comment: 'test'),
      calls: {
        definition: [
          const CallWithArguments(
            receiver: StringConstant('receiver'),
            positionalArguments: [IntConstant(42)],
            namedArguments: {},
            loadingUnits: [loadingUnit1],
          ),
        ],
      },
      instances: {},
    );

    final json = recordings.toJson();
    final roundTripped = Recordings.fromJson(json);

    expect(roundTripped, equals(recordings));

    final usesJson = json['uses'] as Map;
    final recordingsJson = usesJson['static_calls'] as List;
    final recording = recordingsJson[0] as Map;
    final call = (recording['uses'] as List)[0] as Map;
    expect(call.containsKey('receiver'), isTrue);
    final constants = json['constants'] as List;
    final receiverConst = constants[call['receiver'] as int] as Map;
    expect(receiverConst['value'], 'receiver');
  });

  test('CallTearoff with receiver serialization round-trip', () {
    const definition = Definition('package:a/a.dart', [Name('foo')]);
    final recordings = Recordings(
      metadata: Metadata(version: version, comment: 'test'),
      calls: {
        definition: [
          const CallTearoff(
            receiver: StringConstant('receiver'),
            loadingUnits: [loadingUnit1],
          ),
        ],
      },
      instances: {},
    );

    final json = recordings.toJson();
    final roundTripped = Recordings.fromJson(json);

    expect(roundTripped, equals(recordings));

    final usesJson = json['uses'] as Map;
    final recordingsJson = usesJson['static_calls'] as List;
    final recording = recordingsJson[0] as Map;
    final call = (recording['uses'] as List)[0] as Map;
    expect(call['type'], 'tearoff');
    expect(call.containsKey('receiver'), isTrue);
  });
}

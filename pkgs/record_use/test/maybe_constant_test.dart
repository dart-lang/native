// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use.dart';
import 'package:test/test.dart';

const loadingUnit1 = LoadingUnit('1');

void main() {
  test('MaybeConstant arguments in JSON', () {
    const json = {
      'constants': [
        {'type': 'int', 'value': 42},
        {'type': 'unsupported', 'message': 'MethodTearoff'},
        {'type': 'non_constant'},
      ],
      'loading_units': [
        {'name': '1'},
      ],
      'definitions': [
        {
          'uri': 'package:a/a.dart',
          'path': [
            {
              'name': 'foo',
              'kind': 'method',
              'disambiguators': ['static'],
            },
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
                'loading_unit_index': 0,
                'positional': [0, 1, 2],
                'named': {'a': 0, 'b': 1, 'c': 2},
              },
            ],
          },
        ],
      },
    };

    final recordings = Recordings.fromJson(json);
    const definition = Method(
      'foo',
      Library('package:a/a.dart'),
    );
    final calls = recordings.calls[definition]!;
    final call = calls[0] as CallWithArguments;

    expect(call.positionalArguments, hasLength(3));
    expect(call.positionalArguments[0], const IntConstant(42));
    expect(
      call.positionalArguments[1],
      const UnsupportedConstant('MethodTearoff'),
    );
    expect(call.positionalArguments[2], const NonConstant());

    expect(call.namedArguments, hasLength(3));
    expect(call.namedArguments['a'], const IntConstant(42));
    expect(
      call.namedArguments['b'],
      const UnsupportedConstant('MethodTearoff'),
    );
    expect(call.namedArguments['c'], const NonConstant());
  });

  test('MaybeConstant serialization round-trip', () {
    const definition = Method(
      'foo',
      Library('package:a/a.dart'),
    );
    final recordings = Recordings(
      calls: {
        definition: [
          const CallWithArguments(
            positionalArguments: [
              IntConstant(42),
              UnsupportedConstant('MethodTearoff'),
              NonConstant(),
              RecordConstant(
                positional: [IntConstant(1)],
                named: {'a': IntConstant(2)},
              ),
              EnumConstant(
                definition: definition,
                index: 0,
                name: 'red',
                fields: {'hex': IntConstant(0xff0000)},
              ),
              SymbolConstant('foo'),
              SymbolConstant('_bar', libraryUri: 'package:a/a.dart'),
              SetConstant([IntConstant(1), IntConstant(2)]),
            ],
            namedArguments: {
              'a': IntConstant(42),
              'b': UnsupportedConstant('MethodTearoff'),
              'c': NonConstant(),
              'd': RecordConstant(
                positional: [IntConstant(3)],
                named: {'b': IntConstant(4)},
              ),
              'e': EnumConstant(
                definition: definition,
                index: 1,
                name: 'green',
              ),
              'f': SymbolConstant('foo'),
              'g': SymbolConstant('_bar', libraryUri: 'package:a/a.dart'),
              'h': SetConstant([IntConstant(3), IntConstant(4)]),
            },
            loadingUnit: loadingUnit1,
          ),
        ],
      },
      instances: {},
    );

    final json = recordings.toJson();
    final roundTripped = Recordings.fromJson(json);

    expect(roundTripped, equals(recordings));

    // Verify JSON structure specifically for named non-constants
    final usesJson = json['uses'] as Map;
    final recordingsJson = usesJson['static_calls'] as List;
    final recording = recordingsJson[0] as Map;
    final call = (recording['uses'] as List)[0] as Map;
    final named = call['named'] as Map;
    expect(named.containsKey('c'), isTrue);
    expect(named['c'], isNotNull);
    final constants = json['constants'] as List;
    final nonConstant = constants[named['c'] as int] as Map;
    expect(nonConstant['type'], 'non_constant');
  });

  test('allowPromotionOfUnsupported semantic equality', () {
    const definition = Method(
      'foo',
      Library('package:a/a.dart'),
    );

    final actualRecordings = Recordings(
      calls: {
        definition: [
          const CallWithArguments(
            positionalArguments: [IntConstant(42)],
            namedArguments: {'a': StringConstant('bar')},
            loadingUnit: loadingUnit1,
          ),
        ],
      },
      instances: {},
    );

    final expectedRecordings = Recordings(
      calls: {
        definition: [
          const CallWithArguments(
            positionalArguments: [UnsupportedConstant('MethodTearoff')],
            namedArguments: {'a': UnsupportedConstant('MethodTearoff')},
            loadingUnit: loadingUnit1,
          ),
        ],
      },
      instances: {},
    );

    // Should not match by default.
    expect(
      actualRecordings.semanticEquals(
        expectedRecordings,
      ),
      isFalse,
    );

    // Should match when promotion is allowed.
    expect(
      actualRecordings.semanticEquals(
        expectedRecordings,
        allowPromotionOfUnsupported: true,
      ),
      isTrue,
    );

    // Verify it doesn't work the other way around (actual is less specific).
    expect(
      expectedRecordings.semanticEquals(
        actualRecordings,
        allowPromotionOfUnsupported: true,
      ),
      isFalse,
    );
  });
}

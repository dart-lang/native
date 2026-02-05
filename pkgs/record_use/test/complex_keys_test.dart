// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

void main() {
  test('MapConstant with InstanceConstant keys round-trip', () {
    const instanceKey = InstanceConstant(
      fields: {
        'id': IntConstant(1),
        'tag': StringConstant('key'),
      },
    );

    const mapConstant = MapConstant([
      MapEntry(instanceKey, StringConstant('value')),
    ]);

    const definition = Definition(
      identifier: Identifier(
        importUri: 'package:test/test.dart',
        name: 'testMethod',
      ),
    );

    final recordings = Recordings(
      metadata: Metadata(
        version: Version(1, 0, 0),
        comment: 'Test complex keys',
      ),
      callsForDefinition: {
        definition: [
          const CallWithArguments(
            positionalArguments: [mapConstant],
            namedArguments: {},
            loadingUnit: 'main.js',
            location: Location(uri: 'main.dart', line: 1, column: 1),
          ),
        ],
      },
      instancesForDefinition: {},
    );

    final json = recordings.toJson();
    final backAgain = Recordings.fromJson(json);

    expect(backAgain, recordings);
  });

  test('toValue() with InstanceConstant keys', () {
    const instanceKey = InstanceConstant(
      fields: {
        'id': IntConstant(1),
        'tag': StringConstant('key'),
      },
    );

    const mapConstant = MapConstant([
      MapEntry(instanceKey, StringConstant('value')),
    ]);

    final mapValue = mapConstant.toValue() as Map;

    expect(mapValue.keys.first, {
      'id': 1,
      'tag': 'key',
    });
    expect(mapValue.values.first, 'value');
  });

  test('Deeply nested MapConstant with complex keys round-trip', () {
    const listKey = ListConstant([IntConstant(1), IntConstant(2)]);
    const mapKey = MapConstant([
      MapEntry(StringConstant('inner'), IntConstant(3)),
    ]);

    const complexMap = MapConstant([
      MapEntry(listKey, mapKey),
      MapEntry(mapKey, listKey),
    ]);

    const definition = Definition(
      identifier: Identifier(
        importUri: 'package:test/test.dart',
        name: 'complexMethod',
      ),
    );

    final recordings = Recordings(
      metadata: Metadata(
        version: Version(1, 0, 0),
        comment: 'Test deeply nested complex keys',
      ),
      callsForDefinition: {
        definition: [
          const CallWithArguments(
            positionalArguments: [complexMap],
            namedArguments: {},
            loadingUnit: 'main.js',
            location: Location(uri: 'main.dart', line: 1, column: 1),
          ),
        ],
      },
      instancesForDefinition: {},
    );

    final json = recordings.toJson();
    final backAgain = Recordings.fromJson(json);

    expect(backAgain, recordings);
  });

  test('toValue() with deeply nested complex keys', () {
    const listKey = ListConstant([IntConstant(1), IntConstant(2)]);
    const mapKey = MapConstant([
      MapEntry(StringConstant('inner'), IntConstant(3)),
    ]);

    const complexMap = MapConstant([
      MapEntry(listKey, mapKey),
      MapEntry(mapKey, listKey),
    ]);

    final mapValue = complexMap.toValue() as Map;
    expect(mapValue.length, 2);
    final entries = mapValue.entries.toList();
    expect(entries[0].key, [1, 2]);
    expect(entries[0].value, {'inner': 3});
    expect(entries[1].key, {'inner': 3});
    expect(entries[1].value, [1, 2]);
  });
}

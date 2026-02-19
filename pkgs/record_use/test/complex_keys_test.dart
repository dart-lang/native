// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

void main() {
  const classDefinition = Definition(
    'package:test/test.dart',
    [Name('MyClass')],
  );

  test('MapConstant with InstanceConstant keys round-trip', () {
    const instanceKey = InstanceConstant(
      definition: classDefinition,
      fields: {
        'id': IntConstant(1),
        'tag': StringConstant('key'),
      },
    );

    const mapConstant = MapConstant([
      MapEntry(instanceKey, StringConstant('value')),
    ]);

    const definition = Definition(
      'package:test/test.dart',
      [Name('testMethod')],
    );

    final recordings = Recordings(
      metadata: Metadata(
        version: Version(1, 0, 0),
        comment: 'Test complex keys',
      ),
      calls: {
        definition: [
          const CallWithArguments(
            positionalArguments: [mapConstant],
            namedArguments: {},
            loadingUnits: [LoadingUnit('main.js')],
          ),
        ],
      },
      instances: {},
    );

    final json = recordings.toJson();
    final backAgain = Recordings.fromJson(json);

    expect(backAgain, recordings);
  });

  test('MapConstant equality with InstanceConstant keys', () {
    const instanceKey = InstanceConstant(
      definition: classDefinition,
      fields: {
        'id': IntConstant(1),
        'tag': StringConstant('key'),
      },
    );

    const mapConstant = MapConstant([
      MapEntry(instanceKey, StringConstant('value')),
    ]);

    expect(
      mapConstant.entries.first.key,
      const InstanceConstant(
        definition: classDefinition,
        fields: {
          'id': IntConstant(1),
          'tag': StringConstant('key'),
        },
      ),
    );
    expect(mapConstant.entries.first.value, const StringConstant('value'));
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
      'package:test/test.dart',
      [Name('complexMethod')],
    );

    final recordings = Recordings(
      metadata: Metadata(
        version: Version(1, 0, 0),
        comment: 'Test deeply nested complex keys',
      ),
      calls: {
        definition: [
          const CallWithArguments(
            positionalArguments: [complexMap],
            namedArguments: {},
            loadingUnits: [LoadingUnit('main.js')],
          ),
        ],
      },
      instances: {},
    );

    final json = recordings.toJson();
    final backAgain = Recordings.fromJson(json);

    expect(backAgain, recordings);
  });

  test('Deeply nested complex keys structure', () {
    const listKey = ListConstant([IntConstant(1), IntConstant(2)]);
    const mapKey = MapConstant([
      MapEntry(StringConstant('inner'), IntConstant(3)),
    ]);

    const complexMap = MapConstant([
      MapEntry(listKey, mapKey),
      MapEntry(mapKey, listKey),
    ]);

    expect(complexMap.entries, hasLength(2));
    final entries = complexMap.entries;
    expect(
      entries[0].key,
      const ListConstant([IntConstant(1), IntConstant(2)]),
    );
    expect(
      entries[0].value,
      const MapConstant([
        MapEntry(StringConstant('inner'), IntConstant(3)),
      ]),
    );
    expect(
      entries[1].key,
      const MapConstant([
        MapEntry(StringConstant('inner'), IntConstant(3)),
      ]),
    );
    expect(
      entries[1].value,
      const ListConstant([IntConstant(1), IntConstant(2)]),
    );
  });
}

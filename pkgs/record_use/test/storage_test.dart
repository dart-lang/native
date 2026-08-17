// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:record_use/record_use.dart';
import 'package:test/test.dart';

import 'test_data.dart';

void main() {
  group('object 1', () {
    final json = (jsonDecode(recordedUsesJson) as Map<String, Object?>)
      ..remove('\$schema');
    test('JSON', () => expect(recordedUses.toJson(), json));

    test('Object', () => expect(Recordings.fromJson(json), recordedUses));

    test('Json->Object->Json', () {
      expect(Recordings.fromJson(json).toJson(), json);
    });

    test('Object->Json->Object', () {
      expect(Recordings.fromJson(recordedUses.toJson()), recordedUses);
    });
  });

  group('object 2', () {
    final json2 = (jsonDecode(recordedUsesJson2) as Map<String, Object?>)
      ..remove('\$schema');
    test('JSON', () => expect(recordedUses2.toJson(), json2));

    test('Object', () => expect(Recordings.fromJson(json2), recordedUses2));

    test('Json->Object->Json', () {
      expect(Recordings.fromJson(json2).toJson(), json2);
    });

    test('Object->Json->Object', () {
      expect(Recordings.fromJson(recordedUses2.toJson()), recordedUses2);
    });
  });

  group('Recordings deserialization performance and correctness', () {
    test('deserializing large number of constants scales linearly', () {
      const dummyClass = Class(
        'MyClass',
        Library('package:my_package/my_class.dart'),
      );

      // Create a recording with 5,000 distinct instance constants
      const count = 5000;
      final instances = <InstanceConstantReference>[
        for (var i = 0; i < count; i++)
          InstanceConstantReference(
            instanceConstant: InstanceConstant(
              definition: dummyClass,
              fields: {
                'id': IntConstant(i),
                'name': StringConstant('item_$i'),
              },
            ),
            loadingUnit: const LoadingUnit('1'),
          ),
      ];

      final originalRecordings = Recordings(
        calls: {},
        instances: {
          dummyClass: instances,
        },
      );

      final jsonMap = originalRecordings.toJson();

      // Measure deserialization time
      final stopwatch = Stopwatch()..start();
      final deserialized = Recordings.fromJson(jsonMap);
      stopwatch.stop();

      // Deserialization of 5,000 constants should complete well under 1
      // second. Before the fix, this took ~2.3 s due to O(N^2) list
      // containment checks. After the fix, this takes ~12 ms.
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason:
            'Deserialization took ${stopwatch.elapsedMilliseconds}ms, '
            'expected < 1000ms',
      );

      expect(deserialized.instances[dummyClass]?.length, count);
    });
  });
}

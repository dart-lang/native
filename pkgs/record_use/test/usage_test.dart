// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

import 'test_data.dart';

void main() {
  test('All API calls', () {
    expect(
      RecordedUsages.fromJson(
            jsonDecode(recordedUsesJson) as Map<String, Object?>,
          )
          .constArgumentsFor(
            const Definition(
              importUri: 'package:js_runtime/js_helper.dart',
              scope: 'MyClass',
              name: 'get:loadDeferredLibrary',
            ),
          )
          .length,
      2,
    );
  });

  test('All API instances', () {
    final instance =
        RecordedUsages.fromJson(
              jsonDecode(recordedUsesJson) as Map<String, Object?>,
            )
            .constantsOf(
              const Definition(
                importUri: 'package:js_runtime/js_helper.dart',
                name: 'MyAnnotation',
              ),
            )
            .first;
    final instances = recordedUses.instances[instanceId]!
        .whereType<InstanceConstantReference>();
    final instance0 = instances.first.instanceConstant;
    for (final entry in instance0.fields.entries) {
      final field = instance.fields[entry.key];
      expect(field, equals(entry.value));
    }
  });

  test('Specific API calls', () {
    final arguments =
        RecordedUsages.fromJson(
              jsonDecode(recordedUsesJson) as Map<String, Object?>,
            )
            .constArgumentsFor(
              const Definition(
                importUri: 'package:js_runtime/js_helper.dart',
                scope: 'MyClass',
                name: 'get:loadDeferredLibrary',
              ),
            )
            .toList();
    final (named: named0, positional: positional0) = arguments[0];
    expect(named0, {
      'freddy': const StringConstant('mercury'),
      'leroy': const StringConstant('jenkins'),
    });
    expect(positional0, const [
      StringConstant('lib_SHA1'),
      BoolConstant(false),
      IntConstant(1),
    ]);
    final (named: named1, positional: positional1) = arguments[1];
    expect(named1, {
      'freddy': const IntConstant(0),
      'leroy': const StringConstant('jenkins'),
    });
    expect(positional1[0], const StringConstant('lib_SHA1'));
    expect(positional1[1], isA<MapConstant>());
    final map = positional1[1] as MapConstant;
    expect(map.entries[0].key, const StringConstant('key'));
    expect(map.entries[0].value, const IntConstant(99));
  });

  test('Specific API instances', () {
    final instance =
        RecordedUsages.fromJson(
              jsonDecode(recordedUsesJson) as Map<String, Object?>,
            )
            .constantsOf(
              const Definition(
                importUri: 'package:js_runtime/js_helper.dart',
                name: 'MyAnnotation',
              ),
            )
            .first;
    expect(instance.fields['a'], const IntConstant(42));
    expect(instance.fields['b'], isA<NullConstant>());
  });

  test('HasNonConstInstance', () {
    expect(
      RecordedUsages.fromJson(
        jsonDecode(recordedUsesJson2) as Map<String, Object?>,
      ).hasNonConstArguments(
        const Definition(
          importUri:
              'package:drop_dylib_recording/src/drop_dylib_recording.dart',
          name: 'getMathMethod',
        ),
      ),
      false,
    );
  });
}

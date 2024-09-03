// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use.dart';
import 'package:test/test.dart';

import 'storage_test.dart';

void main() {
  test('All API calls', () {
    expect(
      RecordedUsages.fromJson(recordedUsesJson).argumentsTo(callId),
      recordedUses.calls.expand((e) => e.references).map((e) => e.arguments),
    );
  });
  test('All API instances', () {
    expect(
      RecordedUsages.fromJson(recordedUsesJson).instancesOf(instanceId),
      recordedUses.instances
          .expand((e) => e.references)
          .map((e) => Instance(fields: e.fields)),
    );
  });
  test('Specific API calls', () {
    final callId = Identifier(
      uri: Uri.parse('file://lib/_internal/js_runtime/lib/js_helper.dart')
          .toString(),
      parent: 'MyClass',
      name: 'get:loadDeferredLibrary',
    );
    final arguments =
        RecordedUsages.fromJson(recordedUsesJson).argumentsTo(callId)!.toList();
    expect(
      arguments[0].constArguments.named,
      <String, Object>{'leroy': 'jenkins', 'freddy': 'mercury'},
    );
    expect(
      arguments[0].constArguments.positional,
      <int, Object>{0: 'lib_SHA1', 1: false, 2: 1},
    );
    expect(arguments[1].constArguments.named, {
      'leroy': 'jenkins',
      'albert': ['camus', 'einstein']
    });
    expect(arguments[1].constArguments.positional, {
      0: 'lib_SHA1',
      2: 0,
      4: {'key': 99}
    });
  });

  test('Specific API instances', () {
    final instanceId = Identifier(
      uri: Uri.parse('file://lib/_internal/js_runtime/lib/js_helper.dart')
          .toString(),
      name: 'MyAnnotation',
    );
    expect(
      RecordedUsages.fromJson(recordedUsesJson).instancesOf(instanceId)?.first,
      Instance(fields: [Field(name: 'a', className: 'className', value: 42)]),
    );
  });
}

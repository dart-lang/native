// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:record_use/src/data_classes/extensions.dart';
import 'package:record_use/src/record_use.dart';
import 'package:test/test.dart';

import 'testdata/data.dart';

void main() {
  test('API calls', () {
    final callId = Identifier(
      uri: Uri.parse('file://lib/_internal/js_runtime/lib/js_helper.dart')
          .toString(),
      parent: 'MyClass',
      name: 'get:loadDeferredLibrary',
    );
    final arguments = RecordedUsages.fromFile(recordedUses.toBuffer())
        .constArgumentsTo(callId)!
        .toList();
    expect(
      arguments[0].named,
      <String, Object>{'leroy': 'jenkins', 'freddy': 'mercury'},
    );
    expect(
      arguments[0].positional,
      <int, Object>{0: 'lib_SHA1', 1: false, 2: 1},
    );
    expect(arguments[1].named, {
      'leroy': 'jenkins',
      'albert': ['camus', 'einstein']
    });
    expect(arguments[1].positional, {
      0: 'lib_SHA1',
      2: 0,
      4: {'key': 99}
    });
  });
  test('API instances', () {
    final recordedUsesPb = File('test/testdata/data.binpb').readAsBytesSync();
    final instanceId = Identifier(
      uri: Uri.parse('file://lib/_internal/js_runtime/lib/js_helper.dart')
          .toString(),
      name: 'MyAnnotation',
    );
    expect(
      RecordedUsages.fromFile(recordedUsesPb).instanceReferencesTo(instanceId),
      [
        [42]
      ],
    );
  });
}

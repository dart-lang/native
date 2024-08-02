// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:record_use/record_use_internal.dart';
import 'package:record_use/src/record_use.dart';
import 'package:test/test.dart';

import 'testdata/data.dart';

void main() {
  test('Buffer->Object->Buffer', () {
    // Uncomment to reset test files
    // File('test/testdata/data.json')
    //     .writeAsStringSync(recordedUses.toDebugJson());
    // File('test/testdata/data.binpb').writeAsBytesSync(recordedUses.toBuffer());
    final recordedUsesPb = File('test/testdata/data.binpb').readAsBytesSync();
    expect((RecordedUsages.fromFile(recordedUsesPb) as Usages).toBuffer(),
        recordedUsesPb);
  });
  test('Object->Buffer->Object', () {
    expect(
      RecordedUsages.fromFile(recordedUses.toBuffer()),
      recordedUses,
    );
  });
  test('empty Object->Buffer->Object', () {
    expect(
      RecordedUsages.fromFile(emptyUsages.toBuffer()),
      emptyUsages,
    );
  });
}

// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:jni/jni.dart';

import '../test_util/callback_types.dart';

import 'third_party/c_based/dart_bindings/com/fasterxml/jackson/core/_package.dart';

// This file doesn't define main, because only one JVM has to be spawned with
// all classpaths, it's managed at a different file which calls these tests.

void registerTests(String groupName, TestRunnerCallback test) {
  group(groupName, () {
    test('simple json parsing test', () {
      final json = JString.fromString('[1, true, false, 2, 4]');
      JsonFactory factory;
      factory = JsonFactory();
      final parser = factory.createParser6(json);
      final values = <bool>[];
      while (!parser.isClosed()) {
        final next = parser.nextToken();
        if (next.isNull) continue;
        values.add(next.isNumeric());
        next.delete();
      }
      expect(values, equals([false, true, false, false, true, true, false]));
      Jni.deleteAll([factory, parser, json]);
    });
    test("parsing invalid JSON throws JniException", () {
      using((arena) {
        final factory = JsonFactory()..deletedIn(arena);
        final erroneous = factory
            .createParser6("<html>".toJString()..deletedIn(arena))
          ..deletedIn(arena);
        expect(() => erroneous.nextToken(), throwsA(isA<JniException>()));
      });
    });
  });
}

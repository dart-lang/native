// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni/jni.dart';
import 'package:test/test.dart';

import '../test_util/callback_types.dart';
import 'bindings/kotlin.dart';

void registerTests(String groupName, TestRunnerCallback test) {
  group(groupName, () {
    test('Suspend functions', () async {
      await using((arena) async {
        final suspendFun = SuspendFun()..releasedBy(arena);
        final hello = (await suspendFun.sayHello())!;
        expect(hello.toDartString(releaseOriginal: true), 'Hello!');
        const name = 'Bob';
        final helloBob =
            (await suspendFun.sayHello$1(name.toJString()..releasedBy(arena)))!;
        expect(helloBob.toDartString(releaseOriginal: true), 'Hello $name!');
      });
    });

    test('Top levels', () {
      expect(topLevel(), 42);
      expect(topLevelSum(10, 20), 30);
      expect(getTopLevelField(), 42);
      setTopLevelField(30);
      expect(getTopLevelField(), 30);
    });

    test('Generics', () {
      using((arena) {
        final speed = Speed(10, SpeedUnit.MetrePerSec)..releasedBy(arena);
        expect(speed.convertValue(SpeedUnit.KmPerHour), closeTo(36, 1e-6));
      });
    });
  });
}

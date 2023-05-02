// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:jni/jni.dart';

import '../test_util/callback_types.dart';

import 'c_based/dart_bindings/kotlin.dart';

void registerTests(String groupName, TestRunnerCallback test) {
  group(groupName, () {
    test('Suspend functions', () async {
      await using((arena) async {
        final suspendFun = SuspendFun()..deletedIn(arena);
        final hello = await suspendFun.sayHello();
        expect(hello.toDartString(deleteOriginal: true), "Hello!");
        const name = "Bob";
        final helloBob =
            await suspendFun.sayHello1(name.toJString()..deletedIn(arena));
        expect(helloBob.toDartString(deleteOriginal: true), "Hello $name!");
      });
    });
  });
}

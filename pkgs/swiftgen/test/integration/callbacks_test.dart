// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout(Duration(minutes: 2))
library;

import 'dart:async';
import 'dart:ffi';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import 'callbacks_bindings.dart';
import 'util.dart';

void main() {
  group('Callbacks', () {
    setUpAll(() async {
      final gen = TestGenerator('callbacks');
      await gen.generateAndVerifyBindings();
      DynamicLibrary.open(gen.dylibFile);
    });

    test('callback', () async {
      final result = Completer<String>();
      TestMessageService.fetchGreetingWithCompletion(
        ObjCBlock_ffiVoid_NSString.listener((NSString msg) {
          result.complete(msg.toDartString());
        }),
      );
      expect(await result.future, 'Hello from Swift!');
    });

    test('async', () async {
      final result = Completer<String>();
      TestMessageService.fetchGreetingAsyncWithCompletionHandler(
        ObjCBlock_ffiVoid_NSString.listener((NSString msg) {
          result.complete(msg.toDartString());
        }),
      );
      expect(await result.future, 'Hello from Swift async!');
    });

    test('regress #2592', () async {
      // Regression test for https://github.com/dart-lang/native/issues/2952.
      final theObject = NSObject();
      final result = Completer<NSObject?>();
      TestMessageService.echoAsyncObjectWithAnObject(
        theObject,
        completionHandler: ObjCBlock_ffiVoid_NSObject.listener(result.complete),
      );
      expect(await result.future, theObject);
    });
  });
}

// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:objective_c/objective_c.dart';

abstract class SomeObjCObject {
  void greet(NSString greeting);
}

abstract class FooObjCApi {
  SomeObjCObject loadNextObject();
}

abstract class BarObjCApi {
  void sendObject(SomeObjCObject obj);
}

void autoreleaseExample(
  bool longRunningCondition,
  FooObjCApi fooObjCApi,
  BarObjCApi barObjCApi,
) {
  // snippet-start#autorelease_pool
  while (longRunningCondition) {
    // When writing ObjC interop code inside a long running loop, it's a good
    // idea to use an autorelease pool to clean up autoreleased references.
    autoReleasePool(() {
      // Interacting with most ObjC APIs autoreleases a lot of internal refs.
      final someObjCObject = fooObjCApi.loadNextObject();
      someObjCObject.greet('Hello'.toNSString());
      barObjCApi.sendObject(someObjCObject);
    });
  }
  // snippet-end#autorelease_pool
}

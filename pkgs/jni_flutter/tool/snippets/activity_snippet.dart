// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_dynamic_calls, avoid_print, unused_local_variable

import 'dart:ui' show PlatformDispatcher;

import 'package:jni_flutter/jni_flutter.dart';

final engineId = PlatformDispatcher.instance.engineId!;

dynamic someGeneratedApi;
Future<void> someOtherFuture() async {}

// snippet-start#safe
void safeCall() {
  // This is safe because the `Activity` is retrieved and used
  // in a single, unbroken, synchronous block.
  final activity = androidActivity(engineId);
  if (activity != null) {
    someGeneratedApi.doSomething(activity);
    activity.release();
  }
}
// snippet-end#safe

// snippet-start#dangerous
Future<void> dangerousCall() async {
  // 1. Get the Activity (e.g., Activity "A")
  final activity = androidActivity(engineId);

  // 2. An `await` occurs. The main thread is freed.
  //    While waiting, Android might destroy Activity "A" and create "B".
  await someOtherFuture();

  // 3. CRASH: The code resumes, but `activity` is now a stale
  //    reference to the destroyed Activity "A".
  if (activity != null) {
    someGeneratedApi.doSomething(activity); // This will crash
    activity.release();
  }
}
// snippet-end#dangerous

// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:ffi/ffi.dart';
import 'package:jni/jni.dart';

void captureStackTraceExample() {
  // snippet-start#capture_stack_trace
  // Enable stack trace capturing for debugging
  Jni.captureStackTraceOnRelease = true;

  final s = 'hello'.toJString();
  s.release(); // The stack trace is captured here.

  s.release(); // Throws DoubleReleaseError
  // snippet-end#capture_stack_trace
}

void arenaExample() {
  // snippet-start#arena
  using((arena) {
    final s = 'hello'.toJString()..releasedBy(arena);
  });
  // snippet-end#arena
}

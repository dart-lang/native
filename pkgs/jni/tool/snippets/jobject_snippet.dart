// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:jni/jni.dart';

void example(JObject object) {
  // snippet-start
  if (object.isA(JLong.type)) {
    final i = object.as(JLong.type).longValue();
  }
  // snippet-end
}

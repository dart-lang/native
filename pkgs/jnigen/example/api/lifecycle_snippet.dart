// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:ffi/ffi.dart';
import 'package:jni/jni.dart';

dynamic JList;

void releaseManualExample() {
  // snippet-start#release_manual
  // Construct the object.
  final hello = 'Hello'.toJString();
  // Use it.
  print(hello);
  // Eagerly release it!
  hello.release();
  // snippet-end#release_manual
}

void arenaUsingExample() {
  // snippet-start#arena_using
  using((arena) {
    final hello = 'Hello'.toJString()..releasedBy(arena);
    final world = 'World'.toJString()..releasedBy(arena);
    print(hello);
    print(world);
  });
  // Both `hello` and `world` are now released.
  // snippet-end#arena_using
}

void javaCollectionsExample() {
  // snippet-start#java_collections
  // GOOD:
  final jstrings = JList(JString.type);
  using((arena) {
    final hello = 'Hello'.toJString()..releasedBy(arena);
    final world = 'World'.toJString()..releasedBy(arena);
    jstrings.add(hello); // Add to Java collection
    jstrings.add(world); // Add to Java collection
  });
  print(jstrings.length); // prints 2.
  // snippet-end#java_collections
}

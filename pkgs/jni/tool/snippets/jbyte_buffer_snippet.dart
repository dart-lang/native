// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:jni/jni.dart';

void allocateDirectExample() {
  // snippet-start#allocate_direct
  final directBuffer = JByteBuffer.allocateDirect(3);
  directBuffer.asUint8List().setAll(0, [1, 2, 3]);
  // The buffer is now 1, 2, 3.
  // snippet-end#allocate_direct
}

void releaseBufferExample() {
  // snippet-start#release_buffer
  final directBuffer = JByteBuffer.allocateDirect(3);
  final data = directBuffer.asUint8List();
  directBuffer.release(); // Releasing the original buffer.
  data.setAll(0, [1, 2, 3]); // Works! [data] is still accessible.
  // snippet-end#release_buffer
}

void releaseOriginalExample() {
  // snippet-start#release_original
  final directBuffer = JByteBuffer.allocateDirect(3);
  // [releaseOriginal] is `false` by default.
  final data1 = directBuffer.asUint8List();
  directBuffer.nextByte = 42; // No problem!
  print(data1[0]); // prints 42!
  final data2 = directBuffer.asUint8List(releaseOriginal: true);
  // directBuffer.nextByte = 42; // throws [UseAfterReleaseException]!
  // snippet-end#release_original
}

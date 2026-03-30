// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../core_bindings.dart';
import '../jni.dart';
import '../jobject.dart';
import '../jreference.dart';

extension JStringExtension on JString {
  /// The number of Unicode characters in this Java string.
  int get length => Jni.env.GetStringLength(reference.pointer);

  /// Returns the contents as a Dart String.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  String toDartString({bool releaseOriginal = false}) {
    final result = Jni.env.toDartString(reference.pointer);
    if (releaseOriginal) {
      release();
    }
    return result;
  }
}

extension ToJStringMethod on String {
  /// Returns a [JString] with the contents of this String.
  JString toJString() {
    return JObject.fromReference(
      JGlobalReference(Jni.env.toJStringPtr(this)),
    ) as JString;
  }
}

// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../core_bindings.dart';

extension JBooleanExtension on JBoolean {
  /// Returns the value as a Dart bool.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  bool toDartBool({bool releaseOriginal = false}) {
    final ret = booleanValue();
    if (releaseOriginal) {
      release();
    }
    return ret;
  }
}

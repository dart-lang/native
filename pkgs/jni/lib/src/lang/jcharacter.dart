// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../core_bindings.dart';

export '../core_bindings.dart' show JCharacter, JCharacter$$Methods;

extension JCharacterExtension on JCharacter {
  /// Returns the value as a Dart int.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  int toDartCharacter({bool releaseOriginal = false}) {
    final ret = charValue();
    if (releaseOriginal) {
      release();
    }
    return ret;
  }
}

// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

class JniVersionCheck {
  @visibleForTesting
  static const int actualMajorVersion = 1;

  @visibleForTesting
  static const int actualMinorVersion = 0;

  const JniVersionCheck(int major, int minor)
      : assert(
            actualMajorVersion == major && actualMinorVersion >= minor,
            'The generated bindings expect package:jni ^$major.$minor.0, '
            'but $actualMajorVersion.$actualMinorVersion.x was imported.');
}

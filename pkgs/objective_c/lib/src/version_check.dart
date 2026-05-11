// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

class ObjCVersionCheck {
  @visibleForTesting
  static const int actualMajorVersion = 9;

  @visibleForTesting
  static const int actualMinorVersion = 4;

  const ObjCVersionCheck(int major, int minor)
    : assert(
        actualMajorVersion == major && actualMinorVersion >= minor,
        'The generated bindings expect package:objective_c ^$major.$minor.0, '
        'but $actualMajorVersion.$actualMinorVersion.x was imported.',
      );
}

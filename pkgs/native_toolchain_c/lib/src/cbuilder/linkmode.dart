// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';

LinkMode getLinkMode(LinkModePreference preference) {
  if (preference == .dynamic || preference == .preferDynamic) {
    return DynamicLoadingBundled();
  }
  assert(preference == .static || preference == .preferStatic);
  return StaticLinking();
}

// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/code_assets.dart';

LinkMode getLinkMode(LinkModePreference preference) {
  if (preference == LinkModePreference.dynamic ||
      preference == LinkModePreference.preferDynamic) {
    return DynamicLoadingBundled();
  }
  assert(preference == LinkModePreference.static ||
      preference == LinkModePreference.preferStatic);
  return StaticLinking();
}

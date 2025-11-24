// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart' show Version;

// TODO: Delete this version number. Instead of relying on versions, we want to
//   lazy read JSONs so that we don't break on versions that might be
//   incompatible but we don't access any of the incompatible fields.
final version = Version(0, 4, 0);

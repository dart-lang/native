// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

import 'c_bindings_generated.dart' as c;

Version get osVersion => _osVersion;

Version _osVersion = () {
  final ver = c.getOsVesion();
  return Version(ver.major, ver.minor, ver.patch);
}();

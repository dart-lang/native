// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

class ExternalVersions {
  final Versions? ios;
  final Versions? macos;
  const ExternalVersions({this.ios, this.macos});
}

class Versions {
  final Version? min;
  final Version? max;

  const Versions({this.min, this.max});
}

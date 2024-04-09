// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

abstract class HookConfigImpl {
  Uri get configFile;

  Uri get outputFile => outputDirectory.resolve(outputName);

  Uri get outputDirectory;

  Uri get script;

  String toJsonString();

  String get packageName;

  Uri get packageRoot;

  String get outputName;

  Version get version;
}

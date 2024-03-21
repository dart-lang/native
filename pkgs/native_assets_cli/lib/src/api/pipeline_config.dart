// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

part '../model/pipeline_config.dart';

abstract class PipelineConfig {
  Uri get configFile;

  Uri get outputFile => outDirectory.resolve(outputName);

  Uri get outDirectory;

  Uri get script;

  String toJsonString();

  String get packageName;

  Uri get packageRoot;

  String get outputName;
}

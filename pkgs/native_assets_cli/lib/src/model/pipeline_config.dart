// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../utils/yaml.dart';

abstract class PipelineConfig {
  Uri get configFile;

  Uri get output => outDir.resolve(outputName);

  Uri get outDir;

  Uri get script;

  Map<String, Object> toYaml();

  String toYamlString() => yamlEncode(toYaml());

  String get packageName;

  Uri get packageRoot;

  String get outputName;
}

// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigenpad/memfs.dart';
import 'package:ffigenpad/src/config_provider.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'src/ffigen.dart';

void generate(String yaml) {
  final ffigen = FfiGen(logLevel: Level.ALL);
  final config = YamlConfig.fromYaml(loadYaml(yaml) as YamlMap);
  ffigen.run(config);
}

void main(List<String> args) {
  IOOverrides.runWithIOOverrides(() {
    generate(args.first);
  }, MemFSIOOverrides());
}

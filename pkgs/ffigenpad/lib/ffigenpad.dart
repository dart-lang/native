// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:js_interop';

import 'package:ffigenpad/memfs.dart';
import 'package:ffigenpad/src/config_provider.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'src/ffigen.dart';

@JS()
external void addLog(String level, String message);

void generate(String yaml) {
  final ffigen = FfiGen(logLevel: Level.ALL);
  final config = YamlConfig.fromYaml(loadYaml(yaml) as YamlMap);
  config.formatOutput = false;
  ffigen.run(config);
}

void main(List<String> args) {
  Logger.root.onRecord.listen((record) {
    addLog(record.level.name, record.message);
  });
  IOOverrides.runWithIOOverrides(() {
    generate(args.first);
  }, MemFSIOOverrides());
}

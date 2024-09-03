// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import 'memfs.dart';
import 'src/config_provider.dart';
import 'src/ffigen.dart';

@JS()
external void setLogs(JSObject logs);

void generate(String yaml) {
  final ffigen = FfiGen(logLevel: Level.ALL);
  final config = YamlConfig.fromYaml(loadYaml(yaml) as YamlMap);
  ffigen.run(config);
}

void main(List<String> args) {
  final logs = <JSObject>[];
  Logger.root.onRecord.listen((record) {
    final log = JSObject();
    log.setProperty('level'.toJS, (record.level.value / 100).toJS);
    log.setProperty('message'.toJS, record.message.toJS);

    logs.add(log);
  });
  IOOverrides.runWithIOOverrides(() {
    generate(args.first);
  }, MemFSIOOverrides());
  setLogs(logs.toJS);
}

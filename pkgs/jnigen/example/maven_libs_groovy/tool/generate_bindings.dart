// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:logging/logging.dart';

void main() async {
  final packageRoot = Platform.script.resolve('../');
  await JniGenerator(
    input: Input(
      classes: ['com.google.gson.Gson', 'okhttp3.OkHttpClient'],
      androidSdk: AndroidSdk(
        addGradleDeps: true,
        androidExample: packageRoot.resolve('example/'),
      ),
    ),
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('lib/maven_libs_bindings.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
  ).generate();
}

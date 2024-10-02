// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';

void main(List<String> args) async {
  final buildConfig = BuildConfigImpl.fromArguments(args);
  await File.fromUri(buildConfig.outputFile).writeAsString(_wrongContents);
}

const _wrongContents = '''
timestamp: 2023-07-28 14:22:45.000
encodedAssets: []
dependencies: []
metadata: {}
version: 9001.0.0
''';

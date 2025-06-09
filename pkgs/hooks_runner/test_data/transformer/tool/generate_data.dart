// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

void main() async {
  final packageRoot = Platform.script.resolve('../');
  final dataDirectory = packageRoot.resolve('data/');
  const numFiles = 10;
  final encoder = JsonEncoder.withIndent(' ' * 4);
  for (var i = 0; i < numFiles; i++) {
    final file = File.fromUri(dataDirectory.resolve('data$i.json'));
    await file.writeAsString('${encoder.convert({'some_data': i})}\n');
  }
  print('Wrote $numFiles data files to ${dataDirectory.toFilePath()}.');
}

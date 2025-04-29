// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

final _encoder = JsonEncoder.withIndent(' ' * 4);

Future<void> transformFile(File input, File output) async {
  final inputContents = jsonDecode(await input.readAsString());
  final outputContents = {
    'Status': 'I have been transformed!',
    'original': inputContents,
  };
  await output.writeAsString('${_encoder.convert(outputContents)}\n');
}

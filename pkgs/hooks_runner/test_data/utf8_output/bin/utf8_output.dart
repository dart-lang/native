// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final bytes = utf8.encode('你好 爱你 😀\n');
  if (args.single == 'true') {
    // Write partial UTF-8 sequences in separate pipe events.
    for (final byte in bytes) {
      stdout.add([byte]);
      stderr.add([byte]);
      await stdout.flush();
      await stderr.flush();
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  } else {
    stdout.add(bytes);
    stderr.add(bytes);
  }
  await stdout.flush();
  await stderr.flush();
  exitCode = 255;
}

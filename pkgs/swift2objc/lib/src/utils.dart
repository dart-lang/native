// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

Future<String> _runStdout(String executable, List<String> arguments) async {
  final process = await Process.start(executable, arguments);
  final s = StringBuffer();
  process.stdout.transform(utf8.decoder).listen(s.write);
  process.stderr.listen(stderr.add);
  if ((await process.exitCode) != 0) {
    throw ProcessException(executable, arguments);
  }
  return s.toString();
}

Future<String> hostTarget = () async {
  final info =
      json.decode(await _runStdout('swiftc', ['-print-target-info'])) as Map;
  final target = info['target'] as Map;
  return target['triple'] as String;
}();

Future<Uri> hostSdk = () async {
  return Uri.directory((await _runStdout('xcrun', ['--show-sdk-path'])).trim());
}();

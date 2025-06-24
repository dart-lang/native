// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'config.dart';

Future<void> run(
    String executable, List<String> arguments, String workingDir) async {
  final process =
      await Process.start(executable, arguments, workingDirectory: workingDir);
  process.stdout.listen(stdout.add);
  process.stderr.listen(stderr.add);
  if ((await process.exitCode) != 0) {
    throw ProcessException(executable, arguments);
  }
}

Future<String> runGetStdout(String executable, List<String> arguments) async {
  final process = await Process.start(executable, arguments);
  final s = StringBuffer();
  process.stdout.transform(utf8.decoder).listen(s.write);
  process.stderr.listen(stderr.add);
  if ((await process.exitCode) != 0) {
    throw ProcessException(executable, arguments);
  }
  return s.toString();
}

Future<String> getHostTriple() async {
  final info =
      json.decode(await runGetStdout('swiftc', ['-print-target-info'])) as Map;
  final target = info['target'] as Map;
  return target['triple'] as String;
}

Future<Uri> getHostSdk() async =>
    Uri.directory((await runGetStdout('xcrun', ['--show-sdk-path'])).trim());

Future<Target> getHostTarget() async =>
    Target(triple: await getHostTriple(), sdk: await getHostSdk());

Uri createTempDirectory() =>
    Uri.directory(Directory.systemTemp.createTempSync().path);

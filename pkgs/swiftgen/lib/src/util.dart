// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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

Future<Target> getHostTarget() async {
  return Target(
    // TODO: swiftc -print-target-info, target.triple
    triple: 'x86_64-apple-macosx14.0',
    // TODO: xcrun --show-sdk-path
    sdk: Uri.directory(
        '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk'),
  );
}

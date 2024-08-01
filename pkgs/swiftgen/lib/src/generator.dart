// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:swift2objc/swift2objc.dart' as swift2objc;

import 'config.dart';

extension ConfigUtil on Config {
  String get absTempDir => p.absolute(tempDir.toFilePath());
  String get objcHeader => p.join(absTempDir, '${input.module}.h');
}

Future<void> generate(Config config) async {
  Directory(config.absTempDir).createSync(recursive: true);
  await generateObjCSwiftFile(config);
  await generateObjCFile(config);
  await generateDartFile(config);
}

Future<void> generateObjCSwiftFile(Config config) =>
    swift2objc.generateWrapper(swift2objc.Config(
      input: config.input.asSwift2ObjCConfig(config.target),
      outputFile: config.objcSwiftFile,
      tempDir: config.tempDir,
      preamble: config.objcSwiftPreamble,
    ));

Future<void> generateObjCFile(Config config) async {
  await run(config, 'swiftc', [
    '-c', p.absolute(config.objcSwiftFile.toFilePath()),
    '-module-name', config.outputModule,
    '-emit-objc-header-path', config.objcHeader,
    '-target', config.target.triple,
    '-sdk', p.absolute(config.target.sdk.toFilePath()),
  ]);
}

Future<void> generateDartFile(Config config) async {
  // TODO: Invoke ffigen on the generated header.
}

Future<void> run(Config config, String executable, List<String> arguments) async {
  final process = await Process.start(
      executable, arguments,
      workingDirectory: config.absTempDir);
  process.stdout.listen(stdout.add);
  process.stderr.listen(stderr.add);
  if ((await process.exitCode) != 0) {
    throw ProcessException(executable, arguments);
  }
}

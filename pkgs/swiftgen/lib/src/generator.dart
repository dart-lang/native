// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:swift2objc/swift2objc.dart' as swift2objc;

import 'config.dart';

extension ConfigUtil on Config {
  String get absTempDir => p.absolute(tempDir.path);
  String get symbolGraph => p.join(absTempDir, '${input.module}.symbols.json');
  String get absObjcSwiftFile => p.absolute(objcSwiftFile.path);
  String get objcHeader => p.join(absTempDir, '${input.module}.h');
}

Future<void> generate(Config config) async {
  Directory(config.absTempDir).createSync(recursive: true);
  await generateObjCSwiftFile(config);
  await generateObjCFile(config);
  await generateDartFile(config);
}

Future<void> generateObjCSwiftFile(Config config) async {
  await run(config, config.input.symbolGraphCommand(config.target));

  final symbolGraph = config.symbolGraph;
  assert(File(symbolGraph).existsSync());

  final declarations = swift2objc.parseAst(symbolGraph);
  final transformedDeclarations = swift2objc.transform(declarations);
  final generatedSwift = swift2objc.generate(transformedDeclarations);
  await File(config.absObjcSwiftFile).writeAsString('''
import AVFoundation

$generatedSwift
''');
}

Future<void> generateObjCFile(Config config) async {
  await run(config, Command('swiftc', [
    '-c', config.absObjcSwiftFile,
    '-module-name', config.outputModule,
    '-emit-objc-header-path', config.objcHeader,
    '-target', config.target.triple,
    '-sdk', config.target.sdk.path,
  ]));
}

Future<void> generateDartFile(Config config) async {
  // TODO: Invoke ffigen on the generated header.
}

Future<void> run(Config config, Command command) async {
  final process = await Process.start(
      command.executable, command.arguments,
      workingDirectory: config.absTempDir);
  process.stdout.listen(stdout.add);
  process.stderr.listen(stderr.add);
  if ((await process.exitCode) != 0) {
    throw ProcessException(command.executable, command.arguments);
  }
}

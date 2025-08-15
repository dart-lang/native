// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:path/path.dart' as p;
import 'package:swift2objc/swift2objc.dart';
import 'package:test/test.dart';

final _whitespace = RegExp(r'\s+');

void expectString(String a, String b) {
  final trimmedA = a.replaceAll(_whitespace, '');
  final trimmedB = b.replaceAll(_whitespace, '');

  expect(trimmedA, trimmedB);
}

String testDir = p.normalize(
  p.join(
    findPackageRoot('swift2objc').toFilePath(),
    'test',
  ),
);

Future<void> expectValidSwift(List<String> files) async {
  // Try generating symbolgraph for input & output files
  // to make sure the result compiles. Input file must be included cause
  // it contains the definition of the entities the output code wraps.
  final symbolgraphCommand = FilesInputConfig(
    files: files.map(Uri.file).toList(),
    generatedModuleName: 'output_file_symbolgraph',
  ).symbolgraphCommand!;

  final processResult = await Process.run(
    symbolgraphCommand.executable,
    symbolgraphCommand.args,
    workingDirectory: Directory.systemTemp.createTempSync().absolute.path,
  );

  if (processResult.exitCode != 0) {
    print(processResult.stdout);
    print(processResult.stderr);
  }
  expect(processResult.exitCode, 0);
}

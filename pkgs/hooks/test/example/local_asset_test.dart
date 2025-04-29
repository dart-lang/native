// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({'mac-os': Timeout.factor(2), 'windows': Timeout.factor(10)})
library;

import 'dart:io';

import 'package:test/test.dart';

import '../helpers.dart';

void main() async {
  const name = 'local_asset';

  test('local_asset build', () async {
    final testPackageUri = packageUri.resolve('example/build/$name/');
    final dartUri = Uri.file(Platform.resolvedExecutable);
    final processResult = await Process.run(dartUri.toFilePath(), [
      'test/build_test.dart',
    ], workingDirectory: testPackageUri.toFilePath());
    if (processResult.exitCode != 0) {
      print(processResult.stdout);
      print(processResult.stderr);
      print(processResult.exitCode);
    }
    expect(processResult.exitCode, equals(0));
  });
}

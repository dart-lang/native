// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_local_variable

// Objective C support is only available on mac.
@TestOn('mac-os')

// This is a slow test.
@Timeout(Duration(minutes: 30))

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('Large ObjC integration test', () async {
    logWarnings(Level.SEVERE);
    const path = 'test/large_integration_tests/large_objc_config.yaml';
    final config = testConfig(File(path).readAsStringSync(), filename: path);
    final library = parse(config);
    const outFile = 'test/large_integration_tests/large_objc_bindings.dart';
    library.generateFile(File(outFile), format: false);
    expect(File(outFile).existsSync(), isTrue);

    final process = await Process.start('dart', ['analyze', outFile]);
    unawaited(stdout.addStream(process.stdout));
    unawaited(stderr.addStream(process.stderr));
    expect(await process.exitCode, 0);
  });
}

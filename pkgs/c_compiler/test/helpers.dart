// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:test/test.dart';

const keepTempKey = 'KEEP_TEMPORARY_DIRECTORIES';

Future<void> inTempDir(
  Future<void> Function(Uri tempUri) fun, {
  String? prefix,
}) async {
  final tempDir = await Directory.systemTemp.createTemp(prefix);
  try {
    await fun(tempDir.uri);
  } finally {
    if (!Platform.environment.containsKey(keepTempKey) ||
        Platform.environment[keepTempKey]!.isEmpty) {
      await tempDir.delete(recursive: true);
    }
  }
}

final logger = Logger('')
  ..level = Level.ALL
  ..onRecord.listen((record) {
    printOnFailure('${record.level.name}: ${record.time}: ${record.message}');
  });

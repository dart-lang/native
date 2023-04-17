// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
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

/// Logger that outputs the full trace when a test fails.
final logger = Logger('')
  ..level = Level.ALL
  ..onRecord.listen((record) {
    printOnFailure('${record.level.name}: ${record.time}: ${record.message}');
  });

Logger createCapturingLogger(List<String> capturedMessages) => Logger('')
  ..level = Level.ALL
  ..onRecord.listen((record) {
    printOnFailure('${record.level.name}: ${record.time}: ${record.message}');
    capturedMessages.add(record.message);
  });

/// Test files are run in a variety of ways, find this package root in all.
///
/// Test files can be run from source from any working directory. The Dart SDK
/// `tools/test.py` runs them from the root of the SDK for example.
///
/// Test files can be run from dill from the root of package. `package:test`
/// does this.
///
/// https://github.com/dart-lang/test/issues/110
Uri findPackageRoot(String packageName) {
  final script = Platform.script;
  final fileName = script.name;
  if (fileName.endsWith('_test.dart')) {
    // We're likely running from source.
    var directory = script.resolve('.');
    while (true) {
      final dirName = directory.name;
      if (dirName == packageName) {
        return directory;
      }
      final parent = directory.resolve('..');
      if (parent == directory) break;
      directory = parent;
    }
  } else if (fileName.endsWith('.dill')) {
    final cwd = Directory.current.uri;
    final dirName = cwd.name;
    if (dirName == packageName) {
      return cwd;
    }
  }
  throw StateError("Could not find package root for package '$packageName'. "
      'Tried finding the package root via Platform.script '
      "'${Platform.script.toFilePath()}' and Directory.current "
      "'${Directory.current.uri.toFilePath()}'.");
}

Uri packageUri = findPackageRoot('c_compiler');

extension on Uri {
  String get name => pathSegments.where((e) => e != '').last;
}

/// Archiver provided by the environment.
final Uri? ar = Platform.environment['AR']?.asFileUri();

/// Compiler provided by the environment.
final Uri? cc = Platform.environment['CC']?.asFileUri();

/// Linker provided by the environment.
final Uri? ld = Platform.environment['LD']?.asFileUri();

extension on String {
  Uri asFileUri() => Uri.file(this);
}

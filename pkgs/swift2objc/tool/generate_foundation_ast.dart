#!/usr/bin/env dart
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Tool to extract Foundation symbolgraph cache.
///
/// Usage:
///   dart run tool/generate_foundation_ast.dart
library;

import 'dart:io';

import 'package:path/path.dart' as path;

Future<void> main(List<String> arguments) async {
  await _extractFoundation();
}

/// Extract Foundation symbolgraph to cache directory.
Future<void> _extractFoundation() async {
  print('Extracting Foundation symbolgraph...');

  final tempDir = Directory.systemTemp.createTempSync('foundation_extract');

  try {
    // Run swift symbolgraph-extract command
    final result = await Process.run('swift', [
      'symbolgraph-extract',
      '-module-name',
      'Foundation',
      '-target',
      await _getHostTarget(),
      '-sdk',
      await _getHostSdk(),
      '-output-dir',
      tempDir.path,
    ], workingDirectory: tempDir.path);

    if (result.exitCode != 0) {
      stderr.writeln('Error extracting symbolgraph:');
      stderr.writeln(result.stderr);
      exit(1);
    }

    // Copy ALL Foundation*.symbols.json files to hard-coded cache directory
    final destinationDir = Directory(
      path.join('lib', 'src', 'foundation_cache'),
    );

    if (!destinationDir.existsSync()) {
      destinationDir.createSync(recursive: true);
    }

    final symbolgraphFiles = tempDir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.symbols.json'),
    );

    var totalSize = 0;
    for (final file in symbolgraphFiles) {
      final fileName = path.basename(file.path);
      final destination = File(path.join(destinationDir.path, fileName));
      await file.copy(destination.path);
      totalSize += file.lengthSync();
      print('  ✓ $fileName');
    }

    final sizeMB = totalSize / (1024 * 1024);
    print('✓ Foundation symbolgraph saved to ${destinationDir.path}');
    print('  Total size: ${sizeMB.toStringAsFixed(1)}MB');
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}

/// Get the host target triple.
Future<String> _getHostTarget() async {
  if (Platform.isMacOS) {
    final result = await Process.run('uname', ['-m']);
    final arch = (result.stdout as String).trim();
    return '$arch-apple-macosx';
  }
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}

/// Get the host SDK path.
Future<String> _getHostSdk() async {
  if (Platform.isMacOS) {
    final result = await Process.run('xcrun', ['--show-sdk-path']);
    if (result.exitCode != 0) {
      throw Exception('Failed to get SDK path: ${result.stderr}');
    }
    return (result.stdout as String).trim();
  }
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}

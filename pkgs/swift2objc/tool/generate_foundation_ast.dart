#!/usr/bin/env dart
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Tool to extract and optionally verify Foundation symbolgraph cache.
///
/// Usage:
///   dart run tool/generate_foundation_ast.dart
///   dart run tool/generate_foundation_ast.dart --verify
library;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      'verify',
      abbr: 'v',
      help: 'Verify cached symbolgraph matches freshly extracted version',
      negatable: false,
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Output path for extracted symbolgraph',
    );

  final args = parser.parse(arguments);
  final verify = args['verify'] as bool;
  final output = args['output'] as String?;

  if (verify) {
    await _verifyCache();
  } else {
    await _extractFoundation(output);
  }
}

/// Extract Foundation symbolgraph to specified location or cache directory.
Future<void> _extractFoundation(String? outputPath) async {
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

    // Copy ALL Foundation*.symbols.json files
    final destinationDir = outputPath != null
        ? Directory(outputPath)
        : Directory(path.join('lib', 'src', 'foundation_cache'));

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

/// Verify that cached symbolgraph matches freshly extracted version.
Future<void> _verifyCache() async {
  print('Verifying Foundation cache...');

  final cacheDir = Directory(path.join('lib', 'src', 'foundation_cache'));

  if (!cacheDir.existsSync()) {
    stderr.writeln('Error: Cache directory not found');
    exit(1);
  }

  // Extract fresh version to temp location
  final tempDir = Directory.systemTemp.createTempSync('foundation_verify');

  try {
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
    ]);

    if (result.exitCode != 0) {
      stderr.writeln('Error extracting symbolgraph:');
      stderr.writeln(result.stderr);
      exit(1);
    }

    // Get all fresh files
    final freshFiles = tempDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.symbols.json'))
        .toList();

    if (freshFiles.isEmpty) {
      stderr.writeln('Error: No symbolgraph files extracted');
      exit(1);
    }

    // Compare each file
    var allMatch = true;
    for (final freshFile in freshFiles) {
      final fileName = path.basename(freshFile.path);
      final cachedFile = File(path.join(cacheDir.path, fileName));

      if (!cachedFile.existsSync()) {
        stderr.writeln('❌ Missing cached file: $fileName');
        allMatch = false;
        continue;
      }

      // Compare using JSON normalization
      final cachedJson = jsonDecode(await cachedFile.readAsString());
      final freshJson = jsonDecode(await freshFile.readAsString());

      if (_normalizeJson(cachedJson) != _normalizeJson(freshJson)) {
        stderr.writeln('❌ File out of date: $fileName');
        allMatch = false;
      }
    }

    if (!allMatch) {
      stderr.writeln('');
      stderr.writeln('To update the cache, run:');
      stderr.writeln('  cd pkgs/swift2objc');
      stderr.writeln('  dart run tool/generate_foundation_ast.dart');
      exit(1);
    }

    print('✓ All ${freshFiles.length} Foundation cache files are up to date');
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}

/// Normalize JSON for comparison (canonical encoding).
String _normalizeJson(dynamic json) {
  return const JsonEncoder().convert(json);
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

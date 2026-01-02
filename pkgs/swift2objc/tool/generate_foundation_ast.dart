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

    // Read the generated symbolgraph
    final extractedFile = File(
      path.join(tempDir.path, 'Foundation.symbols.json'),
    );

    if (!extractedFile.existsSync()) {
      stderr.writeln('Error: Expected Foundation.symbols.json not found');
      exit(1);
    }

    // Copy to destination
    final destination =
        outputPath ??
        path.join('lib', 'src', 'foundation_cache', 'Foundation.symbols.json');

    await extractedFile.copy(destination);
    final sizeMB = extractedFile.lengthSync() / (1024 * 1024);
    print('✓ Foundation symbolgraph saved to $destination');
    print('  Size: ${sizeMB.toStringAsFixed(1)}MB');
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}

/// Verify that cached symbolgraph matches freshly extracted version.
Future<void> _verifyCache() async {
  print('Verifying Foundation cache...');

  final cachedFile = File(
    path.join('lib', 'src', 'foundation_cache', 'Foundation.symbols.json'),
  );

  if (!cachedFile.existsSync()) {
    stderr.writeln('Error: Cached Foundation.symbols.json not found');
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

    final freshFile = File(path.join(tempDir.path, 'Foundation.symbols.json'));

    if (!freshFile.existsSync()) {
      stderr.writeln('Error: Expected Foundation.symbols.json not found');
      exit(1);
    }

    // Compare using JSON normalization (ignoring whitespace differences)
    final cachedJson = jsonDecode(await cachedFile.readAsString());
    final freshJson = jsonDecode(await freshFile.readAsString());

    final cachedNormalized = _normalizeJson(cachedJson);
    final freshNormalized = _normalizeJson(freshJson);

    if (cachedNormalized != freshNormalized) {
      stderr.writeln('❌ Foundation cache is out of date!');
      stderr.writeln('');
      stderr.writeln('The cached Foundation.symbols.json does not match');
      stderr.writeln('the freshly extracted version.');
      stderr.writeln('');
      stderr.writeln('To update the cache, run:');
      stderr.writeln('  cd pkgs/swift2objc');
      stderr.writeln('  dart run tool/generate_foundation_ast.dart');
      exit(1);
    }

    print('✓ Foundation cache is up to date');
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

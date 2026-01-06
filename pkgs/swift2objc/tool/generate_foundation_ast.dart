#!/usr/bin/env dart
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Script to pre-compile Foundation AST to binary format.
///
/// Reads Foundation.symbols.json, parses it into AST, serializes to compact
/// binary format, and generates .bin file for runtime loading.
///
/// This eliminates JSON parsing overhead (~10 seconds per run).
///
/// Usage: dart run tool/generate_foundation_ast.dart
library;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:swift2objc/src/config.dart';
import 'package:swift2objc/src/context.dart';
import 'package:swift2objc/src/parser/_core/binary_serialization.dart';
import 'package:swift2objc/src/parser/parser.dart';

void main() async {
  print('═══════════════════════════════════════════════════════════════');
  print('Foundation AST Binary Compilation (Phase 2)');
  print('═══════════════════════════════════════════════════════════════\n');

  final jsonPath = path.join(
    'lib',
    'src',
    'foundation_cache',
    'Foundation.symbols.json',
  );

  if (!File(jsonPath).existsSync()) {
    print('❌ Error: Foundation.symbols.json not found at $jsonPath');
    print('Run: swift symbolgraph-extract -module-name Foundation ...');
    exit(1);
  }

  final stopwatch = Stopwatch()..start();

  // Parse JSON
  print('Parsing Foundation.symbols.json...');
  final parseStart = Stopwatch()..start();
  final symbolgraphJson = readJsonFile(jsonPath);
  final parsedSymbolgraph = parseSymbolgraph(
    builtInInputConfig,
    symbolgraphJson,
  );
  parseStart.stop();
  print('✓ JSON parsed in ${parseStart.elapsed.inMilliseconds}ms');

  // Validate
  print('Validating declarations...');
  final context = Context(Logger.detached('codegen')..level = Level.OFF);
  final declarations = parseDeclarations(context, parsedSymbolgraph);
  print('✓ ${declarations.length} declarations parsed');

  // Serialize to binary
  print('\nSerializing to binary format...');
  final serializeStart = Stopwatch()..start();
  final binary = serializeSymbolgraph(parsedSymbolgraph);
  serializeStart.stop();
  print('✓ Serialized in ${serializeStart.elapsed.inMilliseconds}ms');

  // Write binary file
  final binPath = path.join(
    'lib',
    'src',
    'foundation_cache',
    'Foundation.symbols.bin',
  );
  final binFile = File(binPath);
  await binFile.writeAsBytes(binary);

  stopwatch.stop();

  final jsonSize = File(jsonPath).lengthSync();
  final binSize = binary.length;
  final compression = 100.0 * (1.0 - binSize / jsonSize);

  print('\n═══════════════════════════════════════════════════════════════');
  print('Compilation Results');
  print('═══════════════════════════════════════════════════════════════');
  print('Total Time:        ${stopwatch.elapsed.inSeconds}s');
  print('JSON Size:         ${(jsonSize / 1024 / 1024).toStringAsFixed(1)}MB');
  print('Binary Size:       ${(binSize / 1024 / 1024).toStringAsFixed(1)}MB');
  print('Compression:       ${compression.toStringAsFixed(1)}%');
  print('═══════════════════════════════════════════════════════════════');

  print('\n✅ Binary cache generated: $binPath');
  print('\nNext: Update generate_wrapper.dart to load .bin instead of .json\n');
}

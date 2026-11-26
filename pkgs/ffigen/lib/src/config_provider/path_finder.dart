// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utils for finding header paths on system.
library;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'utils.dart' show macSdkPath, xcodePath;

/// This will return include path from either LLVM, XCode or CommandLineTools.
List<String> getCStandardLibraryHeadersForMac(Logger logger) {
  final includePaths = <String>[];

  /// Add system headers.
  final systemHeaders = p.join(macSdkPath, 'usr', 'include');
  if (Directory(systemHeaders).existsSync()) {
    logger.fine('Added $systemHeaders to compiler-opts.');
    includePaths.add('-I$systemHeaders');
  }

  /// Find headers from LLVM installed via brew, Xcode, or CommandLineTools.
  final resourceDir = getClangResourceDirForMac(logger);
  if (resourceDir != null) {
    final path = p.join(resourceDir, 'include');
    logger.fine('Added stdlib path: $path to compiler-opts.');
    includePaths.add('-I$path');
    return includePaths;
  }

  /// If CommandLineTools are installed use those headers.
  const cmdLineToolHeaders =
      '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/Kernel.framework/Headers/';
  if (Directory(cmdLineToolHeaders).existsSync()) {
    logger.fine('Added stdlib path: $cmdLineToolHeaders to compiler-opts.');
    includePaths.add('-I$cmdLineToolHeaders');
    return includePaths;
  }

  // Warnings for missing headers are printed by libclang while parsing.
  logger.fine('Couldn\'t find stdlib headers in default locations.');
  logger.fine('Fallback path searched: $cmdLineToolHeaders');

  return [];
}

/// Finds clang's versioned resource directory (containing `include/`) on macOS.
String? getClangResourceDirForMac(Logger logger) {
  const intelBrewLlvmPath = '/usr/local/opt/llvm/lib/clang';
  const appleSiliconBrewLlvmPath = '/opt/homebrew/opt/llvm/lib/clang';
  final xcodeClangPath = p.join(
    xcodePath,
    'Toolchains',
    'XcodeDefault.xctoolchain',
    'usr',
    'lib',
    'clang',
  );
  const cmdLineToolClangPath =
      '/Library/Developer/CommandLineTools/usr/lib/clang';
  final searchPaths = [
    intelBrewLlvmPath,
    appleSiliconBrewLlvmPath,
    xcodeClangPath,
    cmdLineToolClangPath,
  ];
  for (final searchPath in searchPaths) {
    if (!Directory(searchPath).existsSync()) continue;

    final versions = Directory(searchPath).listSync();
    for (final version in versions) {
      final includePath = p.join(version.path, 'include');
      if (Directory(includePath).existsSync()) {
        logger.fine('Found clang resource dir: ${version.path}');
        return version.path;
      }
    }
  }
  logger.fine(
    'Couldn\'t find clang resource dir in default locations: $searchPaths',
  );
  return null;
}

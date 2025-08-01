// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utils for finding header paths on system.
library;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

/// This will return include path from either LLVM, XCode or CommandLineTools.
List<String> getCStandardLibraryHeadersForMac(Logger logger) {
  final includePaths = <String>[];

  /// Add system headers.
  const systemHeaders =
      '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include';
  if (Directory(systemHeaders).existsSync()) {
    logger.fine('Added $systemHeaders to compiler-opts.');
    includePaths.add('-I$systemHeaders');
  }

  /// Find headers from XCode or LLVM installed via brew.
  const brewLlvmPath = '/usr/local/opt/llvm/lib/clang';
  const xcodeClangPath =
      '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/';
  const searchPaths = [brewLlvmPath, xcodeClangPath];
  for (final searchPath in searchPaths) {
    if (!Directory(searchPath).existsSync()) continue;

    final versions = Directory(searchPath).listSync();
    for (final version in versions) {
      final path = p.join(version.path, 'include');
      if (Directory(path).existsSync()) {
        logger.fine('Added stdlib path: $path to compiler-opts.');
        includePaths.add('-I$path');
        return includePaths;
      }
    }
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
  logger.fine('Paths searched: ${[cmdLineToolHeaders, ...searchPaths]}');

  return [];
}

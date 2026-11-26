// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utils for finding header paths on system.
library;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'utils.dart' show macSdkPath;

/// Returns the C standard library header include path on macOS.
List<String> getCStandardLibraryHeadersForMac(Logger logger) {
  final systemHeaders = p.join(macSdkPath, 'usr', 'include');
  if (Directory(systemHeaders).existsSync()) {
    logger.fine('Added $systemHeaders to compiler-opts.');
    return ['-I$systemHeaders'];
  }

  const cmdLineToolHeaders =
      '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/Kernel.framework/Headers/';
  if (Directory(cmdLineToolHeaders).existsSync()) {
    logger.fine('Added stdlib path: $cmdLineToolHeaders to compiler-opts.');
    return ['-I$cmdLineToolHeaders'];
  }

  // Warnings for missing headers are printed by libclang while parsing.
  logger.fine('Couldn\'t find stdlib headers in default locations.');
  logger.fine('Fallback path searched: $cmdLineToolHeaders');

  return [];
}

/// Finds clang's versioned resource directory (containing `include/`).
///
/// Searches relative to [libclangDylibPath] (including its resolved symlink
/// target).
String? findClangResourceDir(Logger logger, String libclangDylibPath) {
  final candidateClangDirs = <String>{};

  void addCandidatesForDylib(String dylibPath) {
    final parent = p.dirname(dylibPath);
    final grandParent = p.dirname(parent);
    candidateClangDirs
      ..add(p.join(parent, 'clang'))
      ..add(p.join(grandParent, 'lib', 'clang'));
  }

  addCandidatesForDylib(libclangDylibPath);
  final dylibFile = File(libclangDylibPath);
  if (dylibFile.existsSync()) {
    final resolved = dylibFile.resolveSymbolicLinksSync();
    if (resolved != libclangDylibPath) {
      addCandidatesForDylib(resolved);
    }
  }

  for (final clangDir in candidateClangDirs) {
    final dir = Directory(clangDir);
    if (!dir.existsSync()) continue;
    for (final entry in dir.listSync()) {
      if (Directory(p.join(entry.path, 'include')).existsSync()) {
        logger.fine('Found clang resource dir: ${entry.path}');
        return entry.path;
      }
    }
  }

  logger.fine(
    'Couldn\'t find clang resource dir in candidate dirs: $candidateClangDirs',
  );
  return null;
}

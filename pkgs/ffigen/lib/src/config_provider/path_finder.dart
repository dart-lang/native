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
/// target) before falling back to `clang -print-resource-dir`.
String? findClangResourceDir(Logger logger, {String? libclangDylibPath}) {
  final candidateClangDirs = <String>{};

  void addCandidatesForDylib(String dylibPath) {
    final parent = p.dirname(dylibPath);
    final grandParent = p.dirname(parent);
    candidateClangDirs
      ..add(p.join(parent, 'clang'))
      ..add(p.join(grandParent, 'lib', 'clang'));
  }

  if (libclangDylibPath != null) {
    addCandidatesForDylib(libclangDylibPath);
    final dylibFile = File(libclangDylibPath);
    if (dylibFile.existsSync()) {
      final resolved = dylibFile.resolveSymbolicLinksSync();
      if (resolved != libclangDylibPath) {
        addCandidatesForDylib(resolved);
      }
    }
  }

  for (final clangDir in candidateClangDirs) {
    final resourceDir = _findHighestVersionResourceDir(clangDir);
    if (resourceDir != null) {
      logger.fine('Found clang resource dir: $resourceDir');
      return resourceDir;
    }
  }

  try {
    final result = Process.runSync('clang', ['-print-resource-dir']);
    if (result.exitCode == 0) {
      final dir = (result.stdout as String).trim();
      if (dir.isNotEmpty && Directory(p.join(dir, 'include')).existsSync()) {
        logger.fine('Found clang resource dir via clang CLI: $dir');
        return dir;
      }
    }
  } on ProcessException {
    // clang CLI not available on PATH.
  }

  logger.fine(
    'Couldn\'t find clang resource dir in candidate dirs: $candidateClangDirs',
  );
  return null;
}

String? _findHighestVersionResourceDir(String clangDir) {
  final dir = Directory(clangDir);
  if (!dir.existsSync()) return null;

  String? bestDir;
  String? bestVersion;
  for (final entry in dir.listSync()) {
    if (!Directory(p.join(entry.path, 'include')).existsSync()) continue;
    final version = p.basename(entry.path);
    if (bestVersion == null || _compareVersions(version, bestVersion) > 0) {
      bestVersion = version;
      bestDir = entry.path;
    }
  }
  return bestDir;
}

int _compareVersions(String a, String b) {
  final aParts = a.split('.');
  final bParts = b.split('.');
  final len = aParts.length < bParts.length ? aParts.length : bParts.length;
  for (var i = 0; i < len; i++) {
    final aNum = int.tryParse(aParts[i]);
    final bNum = int.tryParse(bParts[i]);
    final cmp = (aNum != null && bNum != null)
        ? aNum.compareTo(bNum)
        : aParts[i].compareTo(bParts[i]);
    if (cmp != 0) return cmp;
  }
  return aParts.length.compareTo(bParts.length);
}

/// Returns `-resource-dir` compiler flags if [existingOpts] does not already
/// specify `-resource-dir`.
List<String> getClangResourceDirOpts(
  Logger logger,
  String libclangDylibPath,
  List<String> existingOpts,
) {
  final hasResourceDir = existingOpts.any(
    (opt) => opt == '-resource-dir' || opt.startsWith('-resource-dir='),
  );
  if (hasResourceDir) return const [];
  final resourceDir = findClangResourceDir(
    logger,
    libclangDylibPath: libclangDylibPath,
  );
  return resourceDir != null ? ['-resource-dir', resourceDir] : const [];
}

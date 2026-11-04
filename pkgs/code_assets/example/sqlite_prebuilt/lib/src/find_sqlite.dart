// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';

final _linuxPaths = {
  Architecture.arm64: <String>[],
  Architecture.x64: ['/usr/lib/x86_64-linux-gnu/libsqlite3.so'],
};

/// Resolves `libsqlite3.so` in default system locations on Linux.
///
/// Shared between `hook/build.dart` and `hook/doctor.dart`.
Uri? findLinuxLibsqlite3() {
  final knownPaths = _linuxPaths[Architecture.current]!;
  for (final knownPath in knownPaths) {
    final file = File(knownPath);
    if (file.existsSync()) {
      return File(file.resolveSymbolicLinksSync()).uri;
    }
  }
  return null;
}

/// Resolves `brew` on `PATH` on macOS.
///
/// Shared between `hook/build.dart` and `hook/doctor.dart`.
Uri? findBrew() {
  final result = Process.runSync('which', ['brew']);
  if (result.exitCode != 0) {
    return null;
  }
  final firstLine = LineSplitter.split(result.stdout as String).first;
  return File(firstLine).uri;
}

/// Resolves `libsqlite3.dylib` via Homebrew on macOS.
///
/// Shared between `hook/build.dart` and `hook/doctor.dart`.
Uri? findMacOSLibsqlite3() {
  if (findBrew() == null) {
    return null;
  }
  final brewPrefixResult = Process.runSync('brew', ['--prefix', 'sqlite']);
  if (brewPrefixResult.exitCode != 0) {
    print(brewPrefixResult.stderr);
    return null;
  }
  final sqliteDir = Uri.directory(
    File((brewPrefixResult.stdout as String).trim()).resolveSymbolicLinksSync(),
  );
  final libsqliteFile = File.fromUri(sqliteDir.resolve('lib/libsqlite3.dylib'));
  if (!libsqliteFile.existsSync()) {
    return null;
  }
  return Uri.file(libsqliteFile.resolveSymbolicLinksSync());
}

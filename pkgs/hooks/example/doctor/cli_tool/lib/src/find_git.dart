// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

/// Resolves `git` on `PATH`.
///
/// Shared between `hook/build.dart` and `hook/doctor.dart`.
Future<Uri?> findGit() async {
  final which = Platform.isWindows ? 'where.exe' : 'which';
  final result = await Process.run(which, ['git']);
  if (result.exitCode != 0) {
    return null;
  }
  final firstLine = LineSplitter.split(result.stdout as String).first;
  return File(firstLine).uri;
}

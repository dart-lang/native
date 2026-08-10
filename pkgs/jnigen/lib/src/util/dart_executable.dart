// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:path/path.dart' as p;

/// The path to the Dart executable.
///
/// This is usually just Platform.resolvedExecutable. But when running flutter
/// tests, the resolvedExecutable will be flutter_tester, and Dart will be in a
/// directory a few levels up from it.
final String dartExecutable = _findDart();

String _findDart() {
  var path = Platform.resolvedExecutable;
  if (p.basenameWithoutExtension(path) == 'dart') return path;
  final dartExe = 'dart${p.extension(path)}';
  while (path.isNotEmpty) {
    path = p.dirname(path);
    final dartPath = p.normalize(p.join(path, dartExe));
    if (File(dartPath).existsSync()) return dartPath;
    final parent = p.dirname(path);
    if (parent == path) break;
  }
  throw Exception(
    "Couldn't find Dart executable near ${Platform.resolvedExecutable}",
  );
}

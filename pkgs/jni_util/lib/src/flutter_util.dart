// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// The path to the `flutter` executable matching the currently running Dart
/// SDK, or `'flutter'` if it cannot be determined.
final String flutterExecutable = findFlutterExecutable(
  resolvedExecutable: Platform.resolvedExecutable,
  isWindows: Platform.isWindows,
);

@visibleForTesting
String findFlutterExecutable({
  required String resolvedExecutable,
  required bool isWindows,
}) {
  if (resolvedExecutable.isEmpty || !p.isAbsolute(resolvedExecutable)) {
    return 'flutter';
  }

  final exeName = isWindows ? 'flutter.bat' : 'flutter';
  var dir = p.dirname(resolvedExecutable);
  // Walk up from resolvedExecutable to find a Flutter SDK's bin/cache/
  // directory and resolve the sibling bin/flutter binary without matching
  // unrelated flutter files.
  while (true) {
    final parent = p.dirname(dir);
    if (parent == dir) {
      break;
    }
    if (p.basename(dir) == 'cache' && p.basename(parent) == 'bin') {
      final candidate = p.join(parent, exeName);
      if (File(candidate).existsSync()) {
        return candidate;
      }
    }
    dir = parent;
  }

  return 'flutter';
}

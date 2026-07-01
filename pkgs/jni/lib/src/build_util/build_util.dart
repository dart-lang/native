// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Any shared build logic should be here. This way it can be reused across bin/,
// tool/ and test/.

import 'dart:io';

const ansiRed = '\x1b[31m';
const ansiDefault = '\x1b[39;49m';

/// Returns true if [artifact] does not exist, or any file in [sourceDir] is
/// newer than [artifact].
bool needsBuild(File artifact, Directory sourceDir) {
  if (!artifact.existsSync()) return true;
  final fileLastModified = artifact.lastModifiedSync();
  for (final entry in sourceDir.listSync(recursive: true)) {
    if (entry.statSync().modified.isAfter(fileLastModified)) {
      return true;
    }
  }
  return false;
}

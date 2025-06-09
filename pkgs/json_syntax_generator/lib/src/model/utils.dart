// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

String indentLines(String text, {int level = 1, int spacesPerLevel = 2}) {
  final indent = ' ' * (level * spacesPerLevel);
  return text.split('\n').map((line) => '$indent$line').join('\n');
}

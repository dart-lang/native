// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// splits [str] into 2 from last occurence of [sep]
List<String> cutFromLast(String str, String sep) {
  final li = str.lastIndexOf(sep);
  if (li == -1) {
    return ['', str];
  }
  return [str.substring(0, li), str.substring(li + 1)];
}

// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

int sum(Iterable<int> values) {
  var val = 0;
  for (var value in values) {
    val += value;
  }
  return val;
}

int product(Iterable<int> values) {
  var val = 1;
  for (var value in values) {
    val *= value;
  }
  return val;
}

// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

extension ListElementEqualsAndHashcode<T> on List<T> {
  int get elementHashCode {
    var result = 37;
    for (final element in this) {
      result ^= element.hashCode;
    }
    return result;
  }

  bool elementEquals(List<T> other) {
    if (length != other.length) {
      return false;
    }
    for (var index = 0; index < length; index++) {
      if (this[index] != other[index]) {
        return false;
      }
    }
    return true;
  }
}

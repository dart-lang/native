// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class DeepCollectionhash {
  int hash(Object? o) {
    var result = 0;
    if (o is Map) {
      for (final entry in o.entries) {
        result = combineOrdered(result, hash(entry.key), hash(entry.value));
      }
    } else if (o is Set) {
      var setHash = 0;
      for (final element in o) {
        setHash = combineUnordered(setHash, hash(element));
      }
      result = combineOrdered(result, setHash);
    } else if (o is List) {
      for (final element in o) {
        result = combineOrdered(result, hash(element));
      }
    } else {
      result = o.hashCode;
    }
    return result;
  }

  int combineOrdered(int hash1, int hash2, [int? hash3]) =>
      Object.hash(hash1, hash2, hash3);

  int combineUnordered(int hash1, int hash2) => hash1 ^ hash2;
}

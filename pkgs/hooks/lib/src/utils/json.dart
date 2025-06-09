// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

extension MapSorting<K extends Comparable<K>, V extends Object?> on Map<K, V> {
  void sortOnKey() {
    final result = <K, V>{};
    final keysSorted = keys.toList()..sort();
    for (final key in keysSorted) {
      result[key] = this[key] as V;
    }
    clear();
    addAll(result);
  }
}

// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

T as<T>(Object? object) {
  if (object is T) {
    return object;
  }
  throw FormatException(
    "Unexpected value '$object' of type ${object.runtimeType} in JSON. Expected"
    ' a $T.',
  );
}

extension MapCast on Map<Object?, Object?> {
  Map<K, V> formatCast<K, V>() => <K, V>{
        for (final e in entries) as<K>(e.key): as<V>(e.value),
      };
}

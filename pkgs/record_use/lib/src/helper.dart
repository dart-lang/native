// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

final deepEquals = const DeepCollectionEquality().equals;

final deepHash = const DeepCollectionEquality().hash;

final _hashCodeCache = Expando<int>();
final _depthCache = Expando<int>();
final _sizeCache = Expando<int>();

extension HashCodeCaching on Object {
  /// Caches the hash code of this object.
  int cacheHashCode(int Function() compute) =>
      _hashCodeCache[this] ??= compute();

  /// Caches the depth of this object.
  int cacheDepth(int Function() compute) => _depthCache[this] ??= compute();

  /// Caches the size of this object.
  int cacheSize(int Function() compute) => _sizeCache[this] ??= compute();
}

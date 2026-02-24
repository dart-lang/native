// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'definition.dart';

/// A loading unit in which a usage of a [Definition] was recorded.
final class LoadingUnit {
  /// The name of the loading unit.
  final String name;

  const LoadingUnit(this.name);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoadingUnit && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'LoadingUnit($name)';
}

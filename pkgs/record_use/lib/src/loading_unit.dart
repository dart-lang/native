// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'canonicalization_context.dart';
import 'definition.dart';

/// A loading unit in which a usage of a [Definition] was recorded.
final class LoadingUnit {
  /// The name of the loading unit.
  final String name;

  const LoadingUnit(this.name);

  /// Canonicalizes the children of this [LoadingUnit].
  LoadingUnit _canonicalizeChildren(CanonicalizationContext context) => this;

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

/// Package private (protected) methods for [LoadingUnit].
///
/// This avoids bloating the public API and public API docs and prevents
/// internal types from leaking from the API.
extension LoadingUnitProtected on LoadingUnit {
  LoadingUnit canonicalizeChildren(CanonicalizationContext context) =>
      _canonicalizeChildren(context);
}

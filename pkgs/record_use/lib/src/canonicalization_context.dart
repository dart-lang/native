// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'constant.dart';
import 'definition.dart';
import 'loading_unit.dart';

/// A context used to canonicalize [Definition]s, [LoadingUnit]s, and
/// [MaybeConstant]s.
class CanonicalizationContext {
  final Set<Definition> _definitions = {};
  final Set<LoadingUnit> _loadingUnits = {};
  final Set<MaybeConstant> _constants = {};

  /// Canonicalizes the given [Definition].
  T canonicalizeDefinition<T extends Definition>(T definition) {
    final existing = _definitions.lookup(definition);
    if (existing != null) return existing as T;
    _definitions.add(definition);
    return definition;
  }

  /// Canonicalizes the given [LoadingUnit].
  LoadingUnit canonicalizeLoadingUnit(LoadingUnit loadingUnit) {
    final existing = _loadingUnits.lookup(loadingUnit);
    if (existing != null) return existing;
    final canonical = LoadingUnitProtected(
      loadingUnit,
    ).canonicalizeChildren(this);
    _loadingUnits.add(canonical);
    return canonical;
  }

  /// Canonicalizes the given [MaybeConstant].
  T canonicalizeConstant<T extends MaybeConstant>(T constant) {
    final existing = _constants.lookup(constant);
    if (existing != null) return existing as T;
    final canonical =
        MaybeConstantProtected(
              constant,
            ).canonicalizeChildren(this)
            as T;
    _constants.add(canonical);
    return canonical;
  }

  /// All canonicalized [Definition]s.
  Iterable<Definition> get definitions => _definitions;

  /// All canonicalized [LoadingUnit]s.
  Iterable<LoadingUnit> get loadingUnits => _loadingUnits;

  /// All canonicalized [MaybeConstant]s.
  Iterable<MaybeConstant> get constants => _constants;
}

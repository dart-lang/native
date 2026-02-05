// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'identifier.dart';
import 'syntax.g.dart';

/// A definition is an [identifier] with its [loadingUnit].
class Definition {
  final Identifier identifier;
  final String? loadingUnit;

  const Definition({required this.identifier, this.loadingUnit});

  factory Definition._fromSyntax(DefinitionSyntax syntax) => Definition(
    identifier: IdentifierProtected.fromSyntax(syntax.identifier),
    loadingUnit: syntax.loadingUnit,
  );

  DefinitionSyntax _toSyntax() => DefinitionSyntax(
    identifier: identifier.toSyntax(),
    loadingUnit: loadingUnit,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Definition &&
        other.identifier == identifier &&
        other.loadingUnit == loadingUnit;
  }

  @override
  int get hashCode => Object.hash(identifier, loadingUnit);

  /// Compares this [Definition] with [other] for semantic equality.
  ///
  /// The [loadingUnit] can be mapped using [loadingUnitMapping].
  /// If [allowLoadingUnitNull] is true, a null [loadingUnit] is considered
  /// equal to any other loading unit.
  ///
  /// The [uriMapping] is passed on to the comparison of the [identifier].
  @visibleForTesting
  bool semanticEquals(
    Definition other, {
    bool allowLoadingUnitNull = false,
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
  }) {
    final skipLoadingUnitComparison =
        allowLoadingUnitNull &&
        (loadingUnit == null || other.loadingUnit == null);
    if (!skipLoadingUnitComparison) {
      final mappedLoadingUnit =
          loadingUnit == null || loadingUnitMapping == null
          ? loadingUnit
          : loadingUnitMapping(loadingUnit!);
      if (other.loadingUnit != mappedLoadingUnit) {
        return false;
      }
    }
    // ignore: invalid_use_of_visible_for_testing_member
    return identifier.semanticEquals(
      other.identifier,
      uriMapping: uriMapping,
    );
  }
}

/// Package private (protected) methods for [Definition].
///
/// This avoids bloating the public API and public API docs and prevents
/// internal types from leaking from the API.
extension DefinitionProtected on Definition {
  DefinitionSyntax toSyntax() => _toSyntax();

  static Definition fromSyntax(DefinitionSyntax syntax) =>
      Definition._fromSyntax(syntax);
}

// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'identifier.dart';
import 'syntax.g.dart';

/// A definition is an [identifier] with its [loadingUnit].
class Definition {
  final Identifier identifier;
  final String? loadingUnit;

  const Definition({required this.identifier, this.loadingUnit});

  factory Definition.fromJson(Map<String, Object?> json) =>
      Definition._fromSyntax(DefinitionSyntax.fromJson(json));

  factory Definition._fromSyntax(DefinitionSyntax syntax) => Definition(
    identifier: IdentifierProtected.fromSyntax(syntax.identifier),
    loadingUnit: syntax.loadingUnit,
  );

  Map<String, Object?> toJson() => _toSyntax().json;

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

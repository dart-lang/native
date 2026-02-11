// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'syntax.g.dart';

/// A unique identifier for a code element, such as a class, method,
/// or field, within a Dart program.
///
/// A [Definition] is used to pinpoint a specific element based on its
/// location and name. It consists of:
///
/// - `importUri`: The URI of the library where the element is defined.
/// - `parent`: The name of the parent element (e.g., the class name for a
///   method or field). This is optional, as not all elements have parents (e.g.
///   top-level functions).
/// - `name`: The name of the element itself.
// TODO(https://github.com/dart-lang/native/issues/2888): Rename to Definition.
class Definition {
  /// The URI of the library where the element is defined.
  ///
  /// This is given in the form of its package import uri, so that it is OS- and
  /// user independent.
  ///
  /// For elements annotated with `@RecordUse`, this URI will always point to a
  /// file in the `lib/` directory of a package.
  final String importUri;

  /// The name of the parent element (e.g., the class name for a method or
  /// field). This is optional, as not all elements have parents (e.g. top-level
  /// functions).
  final String? scope;

  /// The name of the element itself.
  final String name;

  /// Creates a [Definition] object.
  ///
  /// [importUri] is the URI of the library where the element is defined.
  /// [scope] is the optional name of the parent element.
  /// [name] is the name of the element.
  const Definition({required this.importUri, this.scope, required this.name});

  /// Creates a [Definition] object from its syntax representation.
  factory Definition._fromSyntax(DefinitionSyntax syntax) =>
      Definition(importUri: syntax.uri, scope: syntax.scope, name: syntax.name);

  /// Converts this [Definition] object to a syntax representation.
  DefinitionSyntax _toSyntax() =>
      DefinitionSyntax(uri: importUri, scope: scope, name: name);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Definition &&
        other.importUri == importUri &&
        other.scope == scope &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(importUri, scope, name);

  /// Compares this [Definition] with [other] for semantic equality.
  ///
  /// The [importUri] can be mapped using [uriMapping] before comparison.
  @visibleForTesting
  bool semanticEquals(
    Definition other, {
    String Function(String)? uriMapping,
  }) {
    if (other.scope != scope) return false;
    if (other.name != name) return false;
    final mappedImportUri = uriMapping == null
        ? importUri
        : uriMapping(importUri);
    return mappedImportUri == other.importUri;
  }

  @override
  String toString() => scope == null
      ? 'Definition($importUri, $name)'
      : 'Definition($importUri, $scope, $name)';
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

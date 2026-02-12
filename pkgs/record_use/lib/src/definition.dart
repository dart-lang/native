// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'syntax.g.dart';

/// A unique identifier for a code element, such as a class, method,
/// or field, within a Dart program.
///
/// A [Definition] is used to pinpoint a specific element based on its
/// location and name.
// TODO(https://github.com/dart-lang/native/issues/3062): Make this API more
// kind-centric, after we've added support for kinds and disambiguators in the
// compilers.
class Definition {
  /// The URI of the library where the element is defined.
  ///
  /// This must be a `package:` URI, so that it is OS- and user independent.
  ///
  /// For elements annotated with `@RecordUse`, this URI will always point to a
  /// file in the `lib/` directory of a package.
  final String library;

  /// The hierarchical path to the element within the library.
  final List<Name> path;

  /// Creates a [Definition] object.
  const Definition(this.library, this.path);

  /// Creates a [Definition] object from its syntax representation.
  static Definition _fromSyntax(DefinitionSyntax syntax) {
    final path = <Name>[];
    if (syntax.scope != null) {
      path.add(Name(syntax.scope!));
    }
    path.add(Name(syntax.name));
    return Definition(syntax.uri, path);
  }

  /// Converts this [Definition] object to a syntax representation.
  DefinitionSyntax _toSyntax() {
    if (path.length > 2) {
      throw StateError(
        'DefinitionSyntax only supports up to two levels of nesting. '
        'Found ${path.length} levels: $path',
      );
    }
    String? scope;
    if (path.length > 1) {
      scope = path.first.name;
    }
    final name = path.last.name;
    return DefinitionSyntax(uri: library, scope: scope, name: name);
  }

  /// The parent, if it exists.
  Definition? get parent => path.length > 1
      ? Definition(library, path.sublist(0, path.length - 1))
      : null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! Definition) return false;
    if (other.library != library) return false;
    if (other.path.length != path.length) return false;
    for (var i = 0; i < path.length; i++) {
      if (other.path[i] != path[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(library, Object.hashAll(path));

  /// Returns a URI representation of this definition.
  ///
  /// The [library] is the base URI and the [path] is the fragment.
  /// [Name]s in the [path] are separated by `::`.
  @override
  String toString() => '$library#${path.join('::')}';

  /// Compares this [Definition] with [other] for semantic equality.
  ///
  /// The [library] can be mapped using [uriMapping] before comparison.
  @visibleForTesting
  bool semanticEquals(
    Definition other, {
    String Function(String)? uriMapping,
  }) {
    if (other.path.length != path.length) return false;
    for (var i = 0; i < path.length; i++) {
      if (other.path[i] != path[i]) return false;
    }
    final mappedLibrary = uriMapping == null ? library : uriMapping(library);
    return mappedLibrary == other.library;
  }
}

/// A component of a [Definition] path.
class Name {
  /// The name of the element itself.
  final String name;

  /// The kind of the element.
  ///
  /// TODO(https://github.com/dart-lang/native/issues/2888): Make this
  /// non-nullable.
  final DefinitionKind? kind;

  /// Optional disambiguators (e.g. to distinguish between static and instance
  /// members in extensions and extension types).
  final Set<DefinitionDisambiguator> disambiguators;

  const Name(
    this.name, {
    this.kind,
    this.disambiguators = const {},
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! Name) return false;
    if (other.name != name) return false;
    if (other.kind != kind) return false;
    if (other.disambiguators.length != disambiguators.length) return false;
    return disambiguators.every(other.disambiguators.contains);
  }

  @override
  int get hashCode => Object.hash(
    name,
    kind,
    Object.hashAllUnordered(disambiguators),
  );

  /// Returns a string representation of this name that can be used as a part of
  /// a URI fragment.
  ///
  /// The format is `kind:name@disambiguator1@disambiguator2`.
  /// Disambiguators are sorted alphabetically.
  @override
  String toString() {
    final buffer = StringBuffer();
    if (kind != null) {
      buffer.write('$kind:');
    }
    buffer.write(name);
    if (disambiguators.isNotEmpty) {
      final sorted = disambiguators.toList()
        ..sort((a, b) => a.toString().compareTo(b.toString()));
      for (final disambiguator in sorted) {
        buffer.write('@$disambiguator');
      }
    }
    return buffer.toString();
  }
}

/// The kind of code element represented by a [Name].
final class DefinitionKind {
  final String _name;
  const DefinitionKind._(this._name);

  static const classKind = DefinitionKind._('class');
  static const mixinKind = DefinitionKind._('mixin');
  static const enumKind = DefinitionKind._('enum');
  static const extensionKind = DefinitionKind._('extension');
  static const extensionTypeKind = DefinitionKind._('extension_type');
  static const methodKind = DefinitionKind._('method');
  static const getterKind = DefinitionKind._('getter');
  static const setterKind = DefinitionKind._('setter');
  static const operatorKind = DefinitionKind._('operator');
  static const constructorKind = DefinitionKind._('constructor');

  @override
  String toString() => _name;
}

/// Extra metadata to disambiguate between elements that might have the same
/// name and kind.
final class DefinitionDisambiguator {
  final String _name;
  const DefinitionDisambiguator._(this._name);

  /// Applied to members that are static (e.g. a static method in a class).
  ///
  /// Only applies to [DefinitionKind.methodKind], [DefinitionKind.getterKind],
  /// [DefinitionKind.setterKind], and [DefinitionKind.operatorKind].
  static const staticDisambiguator = DefinitionDisambiguator._('static');

  /// Applied to members that are instance members (e.g. an instance method in a
  /// class or extension).
  ///
  /// Only applies to [DefinitionKind.methodKind], [DefinitionKind.getterKind],
  /// [DefinitionKind.setterKind], and [DefinitionKind.operatorKind].
  static const instanceDisambiguator = DefinitionDisambiguator._('instance');

  @override
  String toString() => _name;
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

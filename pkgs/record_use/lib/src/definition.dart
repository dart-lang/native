// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'recordings.dart';
import 'syntax.g.dart';

/// A unique identifier for a code element, such as a [Class] or [Method] within
/// a Dart program.
///
/// A [Definition] is used to pinpoint a specific element based on its location
/// and name.
abstract class Definition {
  /// The name of this definition.
  final String name;

  /// The parent scope that contains this definition.
  final ScopeWithMembers parent;

  const Definition._(this.name, this.parent);

  /// The library where this element is defined.
  Library get library => parent.library;

  NameSyntax _toNameSyntax();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Definition &&
          other.runtimeType == runtimeType &&
          other.name == name &&
          other.parent == parent;

  @override
  int get hashCode => Object.hash(runtimeType, name, parent);

  /// Compares this [Definition] with [other] for semantic equality.
  ///
  /// The library URI can be mapped using [uriMapping] before comparison.
  @visibleForTesting
  bool semanticEquals(
    Definition other, {
    String Function(String)? uriMapping,
  }) {
    if (other.runtimeType != runtimeType) return false;
    if (other.name != name) return false;
    if (!parent._semanticEquals(other.parent, uriMapping: uriMapping)) {
      return false;
    }
    return true;
  }
}

/// A [Library] or [DefinitionWithMembers] which can contain [Member]s.
abstract class ScopeWithMembers {
  const ScopeWithMembers._();

  /// The library which is this scope or contains this scope.
  Library get library;
}

/// A [Definition] for which instances or constant values can be recorded in
/// [Recordings.instances].
abstract interface class DefinitionWithInstances implements Definition {}

/// A [Definition] that can be recorded as a static call in [Recordings.calls].
abstract interface class DefinitionWithStaticCalls implements Definition {
  /// Whether this member is an instance member (declared without the `static`
  /// keyword) or a static member.
  ///
  /// For extension and extension type members, instance members are dispatched
  /// statically and are therefore recorded as static calls in
  /// [Recordings.calls].
  bool get isInstanceMember;
}

extension on ScopeWithMembers {
  String get _prefix => '$this${this is Library ? '#' : '::'}';

  bool _semanticEquals(
    ScopeWithMembers other, {
    String Function(String)? uriMapping,
  }) => switch ((this, other)) {
    (final Library l1, final Library l2) =>
      (uriMapping?.call(l1.uri) ?? l1.uri) == l2.uri,
    (final Definition d1, final Definition d2) => d1.semanticEquals(
      d2,
      uriMapping: uriMapping,
    ),
    _ => false,
  };
}

/// A Dart library.
///
/// Contains [Definition]s via [Definition.parent].
final class Library implements ScopeWithMembers {
  /// The URI of the library in which [Definition]s are defined.
  ///
  /// This must be a `package:` URI, so that it is OS- and user independent.
  final String uri;

  /// Creates a new [Library] with the given [uri].
  const Library(this.uri);

  @override
  Library get library => this;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Library && other.uri == uri;

  @override
  int get hashCode => uri.hashCode;

  @override
  String toString() => uri;
}

/// A [Definition] that can contain other [Member]s.
///
/// For example, a [Class] can contain [Method]s and [Getter]s.
abstract class DefinitionWithMembers extends Definition
    implements ScopeWithMembers {
  const DefinitionWithMembers._(super.name, super.parent) : super._();
}

/// A Dart class.
final class Class extends DefinitionWithMembers
    implements DefinitionWithInstances {
  /// Creates a new [Class] with the given [name] and [parent].
  const Class(super.name, super.parent) : super._();

  @override
  NameSyntax _toNameSyntax() => ClassNameSyntax(name: name);

  @override
  String toString() => '${parent._prefix}class:$name';
}

/// A Dart mixin.
final class Mixin extends DefinitionWithMembers {
  /// Creates a new [Mixin] with the given [name] and [parent].
  const Mixin(super.name, super.parent) : super._();

  @override
  NameSyntax _toNameSyntax() => MixinNameSyntax(name: name);

  @override
  String toString() => '${parent._prefix}mixin:$name';
}

/// A Dart enum.
final class Enum extends DefinitionWithMembers
    implements DefinitionWithInstances {
  /// Creates a new [Enum] with the given [name] and [parent].
  const Enum(super.name, super.parent) : super._();

  @override
  NameSyntax _toNameSyntax() => EnumNameSyntax(name: name);

  @override
  String toString() => '${parent._prefix}enum:$name';
}

/// A Dart extension.
final class Extension extends DefinitionWithMembers {
  /// Creates a new [Extension] with the given [name] and [parent].
  const Extension(super.name, super.parent) : super._();

  @override
  NameSyntax _toNameSyntax() => ExtensionNameSyntax(name: name);

  @override
  String toString() => '${parent._prefix}extension:$name';
}

/// A Dart extension type.
final class ExtensionType extends DefinitionWithMembers {
  /// Creates a new [ExtensionType] with the given [name] and [parent].
  const ExtensionType(super.name, super.parent) : super._();

  @override
  NameSyntax _toNameSyntax() => ExtensionTypeNameSyntax(name: name);

  @override
  String toString() => '${parent._prefix}extension_type:$name';
}

/// A member definition.
abstract class Member extends Definition {
  const Member._(super.name, super.parent) : super._();

  /// Whether this member is an instance member (declared without the `static`
  /// keyword) or a static member.
  ///
  /// For extension and extension type members, instance members are dispatched
  /// statically and are therefore recorded as static calls in
  /// [Recordings.calls].
  bool get isInstanceMember;

  @override
  bool operator ==(Object other) =>
      super == other &&
      other is Member &&
      other.isInstanceMember == isInstanceMember;

  @override
  int get hashCode => Object.hash(super.hashCode, isInstanceMember);

  @override
  bool semanticEquals(
    Definition other, {
    String Function(String)? uriMapping,
  }) {
    if (!super.semanticEquals(other, uriMapping: uriMapping)) return false;
    if (other is! Member) return false;
    return other.isInstanceMember == isInstanceMember;
  }
}

/// A Dart method.
final class Method extends Member implements DefinitionWithStaticCalls {
  @override
  final bool isInstanceMember;

  /// Creates a new [Method] with the given [name] and [parent].
  ///
  /// The [isInstanceMember] flag indicates whether this is an instance member
  /// (declared without the `static` keyword) or a static member.
  const Method(
    super.name,
    super.parent, {
    this.isInstanceMember = false,
  }) : super._();

  @override
  NameSyntax _toNameSyntax() => MethodNameSyntax(
    name: name,
    disambiguators: [isInstanceMember ? 'instance' : 'static'],
  );

  @override
  String toString() {
    final suffix = isInstanceMember ? 'instance' : 'static';
    return '${parent._prefix}method:$name@$suffix';
  }
}

/// A Dart getter.
final class Getter extends Member implements DefinitionWithStaticCalls {
  @override
  final bool isInstanceMember;

  /// Creates a new [Getter] with the given [name] and [parent].
  ///
  /// The [isInstanceMember] flag indicates whether this is an instance member
  /// (declared without the `static` keyword) or a static member.
  const Getter(
    super.name,
    super.parent, {
    this.isInstanceMember = false,
  }) : super._();

  @override
  NameSyntax _toNameSyntax() => GetterNameSyntax(
    name: name,
    disambiguators: [isInstanceMember ? 'instance' : 'static'],
  );

  @override
  String toString() {
    final suffix = isInstanceMember ? 'instance' : 'static';
    return '${parent._prefix}getter:$name@$suffix';
  }
}

/// A Dart setter.
final class Setter extends Member implements DefinitionWithStaticCalls {
  @override
  final bool isInstanceMember;

  /// Creates a new [Setter] with the given [name] and [parent].
  ///
  /// The [isInstanceMember] flag indicates whether this is an instance member
  /// (declared without the `static` keyword) or a static member.
  const Setter(
    super.name,
    super.parent, {
    this.isInstanceMember = false,
  }) : super._();

  @override
  NameSyntax _toNameSyntax() => SetterNameSyntax(
    name: name,
    disambiguators: [isInstanceMember ? 'instance' : 'static'],
  );

  @override
  String toString() {
    final suffix = isInstanceMember ? 'instance' : 'static';
    return '${parent._prefix}setter:$name@$suffix';
  }
}

/// A Dart operator.
final class Operator extends Member implements DefinitionWithStaticCalls {
  @override
  DefinitionWithMembers get parent => super.parent as DefinitionWithMembers;

  /// Creates a new [Operator] with the given [name] and [parent].
  const Operator(super.name, DefinitionWithMembers super.parent) : super._();

  @override
  bool get isInstanceMember => true;

  @override
  NameSyntax _toNameSyntax() => OperatorNameSyntax(name: name);

  @override
  String toString() => '${parent._prefix}operator:$name';
}

/// A Dart constructor.
final class Constructor extends Member {
  @override
  DefinitionWithMembers get parent => super.parent as DefinitionWithMembers;

  /// Creates a new [Constructor] with the given [name] and [parent].
  const Constructor(super.name, DefinitionWithMembers super.parent) : super._();

  @override
  bool get isInstanceMember => false;

  @override
  NameSyntax _toNameSyntax() => ConstructorNameSyntax(name: name);

  @override
  String toString() => '${parent._prefix}constructor:$name';
}

/// Package private (protected) methods for [Definition].
@internal
extension DefinitionProtected on Definition {
  DefinitionSyntax toSyntax() {
    final path = <NameSyntax>[];
    Definition? current = this;
    while (current != null) {
      path.insert(0, current._toNameSyntax());
      final parent = current.parent;
      current = parent is Definition ? parent as Definition : null;
    }

    return DefinitionSyntax(uri: library.uri, definitionPath: path);
  }

  int compareTo(Definition other) => toString().compareTo(other.toString());

  static Definition fromSyntax(DefinitionSyntax syntax) {
    ScopeWithMembers current = Library(syntax.uri);
    final path = syntax.definitionPath;
    for (var i = 0; i < path.length; i++) {
      final nameSyntax = path[i];
      final name = nameSyntax.name;

      final next = switch (nameSyntax) {
        ClassNameSyntax() => Class(name, current),
        MixinNameSyntax() => Mixin(name, current),
        EnumNameSyntax() => Enum(name, current),
        ExtensionNameSyntax() => Extension(name, current),
        ExtensionTypeNameSyntax() => ExtensionType(name, current),
        MethodNameSyntax(:final disambiguators) => Method(
          name,
          current,
          isInstanceMember: switch (disambiguators) {
            ['instance'] => true,
            ['static'] => false,
            _ => throw FormatException(
              'Method requires ["instance"] or ["static"] disambiguator: '
              '$name',
            ),
          },
        ),
        GetterNameSyntax(:final disambiguators) => Getter(
          name,
          current,
          isInstanceMember: switch (disambiguators) {
            ['instance'] => true,
            ['static'] => false,
            _ => throw FormatException(
              'Getter requires ["instance"] or ["static"] disambiguator: '
              '$name',
            ),
          },
        ),
        SetterNameSyntax(:final disambiguators) => Setter(
          name,
          current,
          isInstanceMember: switch (disambiguators) {
            ['instance'] => true,
            ['static'] => false,
            _ => throw FormatException(
              'Setter requires ["instance"] or ["static"] disambiguator: '
              '$name',
            ),
          },
        ),
        OperatorNameSyntax() => Operator(
          name,
          current as DefinitionWithMembers,
        ),
        ConstructorNameSyntax() => Constructor(
          name,
          current as DefinitionWithMembers,
        ),
        _ => throw FormatException(
          'Unknown definition kind: ${nameSyntax.kind}',
        ),
      };
      if (i < path.length - 1) {
        current = next as ScopeWithMembers;
      } else {
        return next;
      }
    }
    throw const FormatException('Empty definition path');
  }
}

/// Package private (protected) methods for [Library].
@internal
extension LibraryProtected on Library {
  int compareTo(Library other) => uri.compareTo(other.uri);
}

// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

import 'data_classes/extensions.dart';
import 'proto/usages_read.pb.dart' as pb;
import 'proto/usages_storage.pb.dart' as pb_storage;

class Identifier {
  final String uri;
  final String? parent;
  final String name;

  const Identifier({required this.uri, this.parent, required this.name});
}

extension type RecordedUsages._(pb.Usages _usages) {
  RecordedUsages.fromFile(Uint8List contents)
      : this._(pb_storage.Usages.fromBuffer(contents).toApi());

  /// Show the metadata for this recording of usages.
  Version get version => Version.parse(_usages.metadata.version);

  /// Finds all arguments for calls to the [method].
  ///
  /// The definition must be annotated with `@RecordUse()`. If there are no
  /// calls to the definition, either because it was treeshaken, because it was
  /// not annotated, or because it does not exist, returns `null`.
  ///
  /// Returns an empty iterable if the arguments were not collected.
  ///
  /// Example:
  /// ```dart
  /// import 'package:meta/meta.dart' show ResourceIdentifier;
  /// void main() {
  ///   print(SomeClass.someStaticMethod(42));
  /// }
  ///
  /// class SomeClass {
  ///   @ResourceIdentifier('id')
  ///   static someStaticMethod(int i) {
  ///     return i + 1;
  ///   }
  /// }
  /// ```
  ///
  /// Would mean that
  /// ```
  /// argumentsForCallsTo(Identifier(
  ///           uri: 'path/to/file.dart',
  ///           parent: 'SomeClass',
  ///           name: 'someStaticMethod'),
  ///       ).first ==
  ///       Arguments(
  ///         constArguments: ConstArguments(positional: {1: 42}),
  ///       );
  /// ```
  Iterable<({Map<String, Object> named, Map<int, Object> positional})>?
      constArgumentsTo(Identifier method) =>
          _callTo(method)?.references.map((reference) => (
                named: reference.arguments.constArguments.named.map(
                  (key, value) => MapEntry(key, value.toObject()),
                ),
                positional: reference.arguments.constArguments.positional.map(
                  (key, value) => MapEntry(key, value.toObject()),
                ),
              ));

  /// Finds all fields of a const instance of the class at [classIdentifier].
  ///
  /// The definition must be annotated with `@RecordUse()`. If there are
  /// no instances of the definition, either because it was treeshaken, because
  /// it was not annotated, or because it does not exist, returns `null`.
  ///
  /// The types of fields supported are defined at
  /// TODO: insert reference to the supported field types for serialization
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   print(SomeClass.someStaticMethod(42));
  /// }
  ///
  /// class SomeClass {
  ///   @AnnotationClass('freddie')
  ///   static someStaticMethod(int i) {
  ///     return i + 1;
  ///   }
  /// }
  ///
  /// @ResourceIdentifier()
  /// class AnnotationClass {
  ///   final String s;
  ///   const AnnotationClass(this.s);
  /// }
  /// ```
  ///
  /// Would mean that
  /// ```
  /// fieldsForConstructionOf(Identifier(
  ///           uri: 'path/to/file.dart',
  ///           name: 'AnnotationClass'),
  ///       ).first ==
  ///       [
  ///         Field(name: "s", className: "AnnotationClass", value: "freddie")
  ///       ];
  /// ```
  ///
  /// What kinds of fields can be recorded depends on the implementation of
  /// https://dart-review.googlesource.com/c/sdk/+/369620/13/pkg/vm/lib/transformations/record_use/record_instance.dart
  Iterable<Iterable<Object>>? instanceReferencesTo(Identifier classIdentifier) {
    final instances = _usages.instances;
    final firstWhereOrNull = instances.firstWhereOrNull((instance) =>
        _compareIdentifiers(instance.definition.identifier, classIdentifier));
    return firstWhereOrNull?.references.map((reference) =>
        reference.fields.fields.map((field) => field.value.toObject()));
  }

  /// Checks if any call to [method] has non-const arguments.
  ///
  /// The definition must be annotated with `@RecordUse()`. If there are no
  /// calls to the definition, either because it was treeshaken, because it was
  /// not annotated, or because it does not exist, returns `false`.
  bool hasNonConstArguments(Identifier method) =>
      _callTo(method)?.references.any(
        (reference) {
          final nonConstArguments = reference.arguments.nonConstArguments;
          final hasNamed = nonConstArguments.named.isNotEmpty;
          final hasPositional = nonConstArguments.positional.isNotEmpty;
          return hasNamed || hasPositional;
        },
      ) ??
      false;

  pb.Usage? _callTo(Identifier identifier) => _usages.calls.firstWhereOrNull(
      (call) => _compareIdentifiers(call.definition.identifier, identifier));

  bool _compareIdentifiers(pb.Identifier id1, Identifier id2) =>
      id1.uri == id2.uri &&
      (id1.hasParent() ? id1.parent : null) == id2.parent &&
      id1.name == id2.name;
}

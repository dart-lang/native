// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'data_classes/arguments.dart';
import 'data_classes/field.dart';
import 'data_classes/identifier.dart';
import 'data_classes/metadata.dart';
import 'data_classes/reference.dart';
import 'data_classes/usage.dart';
import 'data_classes/usage_record.dart';

extension type RecordUse._(UsageRecord _recordUses) {
  RecordUse.fromJson(Map<String, dynamic> json)
      : this._(UsageRecord.fromJson(json));

  /// Show the metadata for this recording of usages.
  Metadata get metadata => _recordUses.metadata;

  /// Finds all arguments for calls to the [definition].
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
  Iterable<Arguments>? callReferencesTo(Identifier definition) =>
      _callTo(definition)
          ?.references
          .map((reference) => reference.arguments)
          .whereType();

  /// Finds all fields of a const instance of the class at [definition].
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
  Iterable<List<Field>>? instanceReferencesTo(Identifier definition) =>
      _recordUses.instances
          .firstWhereOrNull(
              (instance) => instance.definition.identifier == definition)
          ?.references
          .map((reference) => reference.fields);

  /// Checks if any call to [definition] has non-const arguments.
  ///
  /// The definition must be annotated with `@RecordUse()`. If there are no
  /// calls to the definition, either because it was treeshaken, because it was
  /// not annotated, or because it does not exist, returns `false`.
  bool hasNonConstArguments(Identifier definition) =>
      _callTo(definition)?.references.any(
        (reference) {
          final nonConstArguments = reference.arguments?.nonConstArguments;
          final hasNamed = nonConstArguments?.named.isNotEmpty ?? false;
          final hasPositional =
              nonConstArguments?.positional.isNotEmpty ?? false;
          return hasNamed || hasPositional;
        },
      ) ??
      false;

  Usage<CallReference>? _callTo(Identifier definition) => _recordUses.calls
      .firstWhereOrNull((call) => call.definition.identifier == definition);
}

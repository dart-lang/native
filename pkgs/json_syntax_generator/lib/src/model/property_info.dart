// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../parser/schema_analyzer.dart';
import 'dart_type.dart';

class PropertyInfo {
  /// The Dart getter and setter name.
  final String name;

  /// The key in the json object for this property.
  final String jsonKey;

  /// The Dart type for this property.
  final DartType type;

  /// Whether this property overrides a super property.
  ///
  /// Overrides must have a more specific type. This means no setter for this
  /// property will be generated on subclasses. A more specific getter, and a
  /// more specific constructor param are generated.
  final bool isOverride;

  /// Whether the setter is private.
  ///
  /// By default, setters are hidden. Constructors are visible and constructors
  /// have required parameters for all required fields. This force the generate
  /// syntax API user to provide all required fields.
  ///
  /// Some use cases require public setters as the object is constructed peace
  /// meal. See [SchemaAnalyzer.publicSetters].
  final bool setterPrivate;

  bool get isRequired => !type.isNullable;

  PropertyInfo({
    required this.name,
    required this.jsonKey,
    required this.type,
    this.isOverride = false,
    this.setterPrivate = true,
  });

  @override
  String toString() => '''
PropertyInfo(
  name: $name,
  jsonKey: $jsonKey,
  type: $type,
  isOverride: $isOverride,
  setterPrivate: $setterPrivate,
  isRequired: $isRequired
)''';
}

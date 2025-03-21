// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'property_info.dart';
import 'utils.dart';

sealed class ClassInfo {
  /// The Dart class name.
  final String name;

  ClassInfo({required this.name});
}

class NormalClassInfo extends ClassInfo {
  /// Reference to the super class.
  final NormalClassInfo? superclass;

  /// References to all subclasses.
  ///
  /// Constructed lazily on instantiating sub classes.
  final List<NormalClassInfo> subclasses = [];

  /// The properties of this class.
  ///
  /// Includes properties that override properties in a super class. Does not
  /// include properties not overridden in the super class.
  final List<PropertyInfo> properties;

  PropertyInfo? getProperty(String name) =>
      properties.where((e) => e.name == name).firstOrNull;

  /// The Dart property identifying a tagged union.
  ///
  /// Only set in the parent class.
  final String? taggedUnionProperty;

  /// The String value identifying the subtype in a tagged union.
  ///
  /// Only set in the sub classes.
  final String? taggedUnionValue;

  bool get isTaggedUnion =>
      taggedUnionProperty != null || taggedUnionValue != null;

  NormalClassInfo({
    required super.name,
    this.superclass,
    required this.properties,
    this.taggedUnionProperty,
    this.taggedUnionValue,
  }) : super() {
    superclass?.subclasses.add(this);
    if (taggedUnionValue != null) {
      assert(superclass != null);
    }
  }

  @override
  String toString() {
    final propertiesString = properties
        .map((p) => indentLines(p.toString(), level: 2))
        .join(',\n');
    return '''
$runtimeType(
  name: $name,
  superclassName: ${superclass?.name},
  subclassNames: [ ${subclasses.map((e) => e.name).join(', ')} ],
  properties: [
$propertiesString
  ],
  taggedUnionProperty: $taggedUnionProperty,
  taggedUnionValue: $taggedUnionValue,
)''';
  }
}

class EnumClassInfo extends ClassInfo {
  final List<EnumValue> enumValues;
  final bool isOpen;

  EnumClassInfo({
    required super.name,
    required this.enumValues,
    required this.isOpen,
  }) : super();

  @override
  String toString() {
    final enumValuesString = enumValues
        .map((p) => indentLines(p.toString(), level: 2))
        .join(',\n');
    return '''
$runtimeType(
  name: $name,
  enumValues: [
$enumValuesString
  ],
  isOpen: $isOpen
)''';
  }
}

class EnumValue {
  final String jsonValue;
  final String name;

  EnumValue({required this.jsonValue, required this.name});

  @override
  String toString() => '''
$runtimeType(
  name: $name,
  jsonValue: $jsonValue
)''';
}

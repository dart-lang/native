// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'property_info.dart';
import 'utils.dart';

sealed class ClassInfo {
  /// The Dart class name.
  final String name;

  /// Reference to the super class.
  final ClassInfo? superclass;

  /// References to all subclasses.
  ///
  /// Constructed lazily on instantiating sub classes.
  final List<ClassInfo> subclasses = [];

  /// The properties of this class.
  ///
  /// Includes properties that override properties in a super class. Does not
  /// include properties not overridden in the super class.
  final List<PropertyInfo> properties;

  ClassInfo({required this.name, this.superclass, required this.properties}) {
    superclass?.subclasses.add(this);
  }

  PropertyInfo? getProperty(String name) =>
      properties.where((e) => e.name == name).firstOrNull;
}

class NormalClassInfo extends ClassInfo {
  final String? taggedUnionKey;

  NormalClassInfo({
    required super.name,
    super.superclass,
    required super.properties,
    required this.taggedUnionKey,
  }) : super();

  @override
  String toString() {
    final propertiesString = properties
        .map((p) => indentLines(p.toString(), level: 2))
        .join(',\n');
    return '''
$runtimeType(
  name: $name,
  superclassName: ${superclass?.name},
  subclassNames: [ ${subclasses.map((e) => e.name).join(', ')} ]
  properties: [
$propertiesString
  ],
  taggedUnionKey: $taggedUnionKey
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
  }) : super(properties: const []);

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

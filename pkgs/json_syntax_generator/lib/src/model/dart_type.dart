// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'class_info.dart';

sealed class DartType {
  final bool isNullable;

  const DartType({required this.isNullable});

  @override
  String toString() {
    final typeString = toNonNullableString();
    return isNullable ? '$typeString?' : typeString;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DartType && isNullable == other.isNullable;

  @override
  int get hashCode => isNullable.hashCode;

  String toNonNullableString();
}

/// A simple Dart type.
///
/// Types that don't need any encoding or decoding for JSON objects.
sealed class SimpleDartType extends DartType {
  final String typeName;

  const SimpleDartType({required this.typeName, required super.isNullable});

  @override
  String toNonNullableString() => typeName;

  @override
  bool operator ==(Object other) =>
      super == other && other is SimpleDartType && typeName == other.typeName;

  @override
  int get hashCode => Object.hash(super.hashCode, typeName);
}

class StringDartType extends SimpleDartType {
  const StringDartType({required super.isNullable}) : super(typeName: 'String');

  @override
  bool operator ==(Object other) => super == other && other is StringDartType;

  @override
  int get hashCode => Object.hash(super.hashCode, 'String');
}

class IntDartType extends SimpleDartType {
  const IntDartType({required super.isNullable}) : super(typeName: 'int');

  @override
  bool operator ==(Object other) => super == other && other is IntDartType;

  @override
  int get hashCode => Object.hash(super.hashCode, 'int');
}

class BoolDartType extends SimpleDartType {
  const BoolDartType({required super.isNullable}) : super(typeName: 'bool');

  @override
  bool operator ==(Object other) => super == other && other is BoolDartType;

  @override
  int get hashCode => Object.hash(super.hashCode, 'bool');
}

class ObjectDartType extends SimpleDartType {
  const ObjectDartType({required super.isNullable}) : super(typeName: 'Object');

  @override
  bool operator ==(Object other) => super == other && other is ObjectDartType;

  @override
  int get hashCode => Object.hash(super.hashCode, 'Object');
}

class ClassDartType extends DartType {
  final ClassInfo classInfo;

  const ClassDartType({required this.classInfo, required super.isNullable});

  @override
  String toNonNullableString() => classInfo.className;

  @override
  bool operator ==(Object other) =>
      super == other && other is ClassDartType && classInfo == other.classInfo;

  @override
  int get hashCode => Object.hash(super.hashCode, classInfo);
}

/// The [ClassInfo] for the `JsonObject` base class.
final jsonObjectClassInfo = NormalClassInfo(name: 'JsonObject', properties: []);

class ListDartType extends DartType {
  final DartType itemType;

  const ListDartType({required this.itemType, required super.isNullable});

  @override
  String toNonNullableString() => 'List<$itemType>';

  @override
  bool operator ==(Object other) =>
      super == other && other is ListDartType && itemType == other.itemType;

  @override
  int get hashCode => Object.hash(super.hashCode, itemType);
}

class MapDartType extends DartType {
  final DartType keyType;
  final DartType valueType;

  const MapDartType({
    this.keyType = const StringDartType(isNullable: false),
    required this.valueType,
    required super.isNullable,
  });

  @override
  String toNonNullableString() => 'Map<$keyType, $valueType>';

  @override
  bool operator ==(Object other) =>
      super == other &&
      other is MapDartType &&
      keyType == other.keyType &&
      valueType == other.valueType;

  @override
  int get hashCode => Object.hash(super.hashCode, keyType, valueType);
}

class UriDartType extends DartType {
  const UriDartType({required super.isNullable});

  @override
  String toNonNullableString() => 'Uri';

  @override
  bool operator ==(Object other) => super == other && other is UriDartType;

  @override
  int get hashCode => Object.hash(super.hashCode, 'Uri');
}

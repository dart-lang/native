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
}

class StringDartType extends SimpleDartType {
  const StringDartType({required super.isNullable}) : super(typeName: 'String');
}

class IntDartType extends SimpleDartType {
  const IntDartType({required super.isNullable}) : super(typeName: 'int');
}

class BoolDartType extends SimpleDartType {
  const BoolDartType({required super.isNullable}) : super(typeName: 'bool');
}

class ObjectDartType extends SimpleDartType {
  const ObjectDartType({required super.isNullable}) : super(typeName: 'Object');
}

class ClassDartType extends DartType {
  final ClassInfo classInfo;

  const ClassDartType({required this.classInfo, required super.isNullable});

  @override
  String toNonNullableString() => classInfo.name;
}

class ListDartType extends DartType {
  final DartType itemType;

  const ListDartType({required this.itemType, required super.isNullable});

  @override
  String toNonNullableString() => 'List<$itemType>';
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
}

class UriDartType extends DartType {
  const UriDartType({required super.isNullable});

  @override
  String toNonNullableString() => 'Uri';
}

// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// The types here are mapped to primitive types in Java, so they're all in
// lowercase.
// ignore_for_file: camel_case_types

part of 'types.dart';

abstract final class JPrimitive {}

abstract final class jbyte extends JPrimitive {
  static const type = jbyteType();
}

final class jbyteType extends JType<jbyte> {
  const jbyteType();

  @override
  final signature = 'B';
}

abstract final class jboolean extends JPrimitive {
  static const type = jbooleanType();
}

final class jbooleanType extends JType<jboolean> {
  const jbooleanType();

  @override
  final signature = 'Z';
}

abstract final class jchar extends JPrimitive {
  static const type = jcharType();
}

final class jcharType extends JType<jchar> {
  const jcharType();

  @override
  final signature = 'C';
}

abstract final class jshort extends JPrimitive {
  static const type = jshortType();
}

final class jshortType extends JType<jshort> {
  const jshortType();

  @override
  final signature = 'S';
}

abstract final class jint extends JPrimitive {
  static const type = jintType();
}

final class jintType extends JType<jint> {
  const jintType();

  @override
  final signature = 'I';
}

abstract final class jlong extends JPrimitive {
  static const type = jlongType();
}

final class jlongType extends JType<jlong> {
  const jlongType();

  @override
  final signature = 'J';
}

abstract final class jfloat extends JPrimitive {
  static const type = jfloatType();
}

final class jfloatType extends JType<jfloat> {
  const jfloatType();

  @override
  final signature = 'F';
}

abstract final class jdouble extends JPrimitive {
  static const type = jdoubleType();
}

final class jdoubleType extends JType<jdouble> {
  const jdoubleType();

  @override
  final signature = 'D';
}

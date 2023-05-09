// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// The types here are mapped to primitive types in Java, so they're all in
// lowercase.
// ignore_for_file: camel_case_types

import 'types.dart';

abstract class JPrimitive {}

abstract class jbyte extends JPrimitive {
  static const type = jbyteType();
}

class jbyteType extends JType<jbyte> {
  const jbyteType();

  @override
  final signature = 'B';
}

abstract class jboolean extends JPrimitive {
  static const type = jbooleanType();
}

class jbooleanType extends JType<jboolean> {
  const jbooleanType();

  @override
  final signature = 'Z';
}

abstract class jchar extends JPrimitive {
  static const type = jcharType();
}

class jcharType extends JType<jchar> {
  const jcharType();

  @override
  final signature = 'C';
}

abstract class jshort extends JPrimitive {
  static const type = jshortType();
}

class jshortType extends JType<jshort> {
  const jshortType();

  @override
  final signature = 'S';
}

abstract class jint extends JPrimitive {
  static const type = jintType();
}

class jintType extends JType<jint> {
  const jintType();

  @override
  final signature = 'I';
}

abstract class jlong extends JPrimitive {
  static const type = jlongType();
}

class jlongType extends JType<jlong> {
  const jlongType();

  @override
  final signature = 'J';
}

abstract class jfloat extends JPrimitive {
  static const type = jfloatType();
}

class jfloatType extends JType<jfloat> {
  const jfloatType();

  @override
  final signature = 'F';
}

abstract class jdouble extends JPrimitive {
  static const type = jdoubleType();
}

class jdoubleType extends JType<jdouble> {
  const jdoubleType();

  @override
  final signature = 'D';
}

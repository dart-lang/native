// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// The types here are mapped to primitive types in Java, so they're all in
// lowercase.
// ignore_for_file: camel_case_types

import 'third_party/generated_bindings.dart';
import 'types.dart';

abstract class JPrimitive {}

abstract class jbyte extends JPrimitive {
  static const type = jbyteType();
}

class jbyteType extends JType<jbyte> {
  const jbyteType();

  @override
  int get callType => JniCallType.byteType;

  @override
  String get signature => "B";
}

abstract class jboolean extends JPrimitive {
  static const type = jbooleanType();
}

class jbooleanType extends JType<jboolean> {
  const jbooleanType();

  @override
  int get callType => JniCallType.booleanType;

  @override
  String get signature => "Z";
}

abstract class jchar extends JPrimitive {
  static const type = jcharType();
}

class jcharType extends JType<jchar> {
  const jcharType();

  @override
  int get callType => JniCallType.charType;

  @override
  String get signature => "C";
}

abstract class jshort extends JPrimitive {
  static const type = jshortType();
}

class jshortType extends JType<jshort> {
  const jshortType();

  @override
  int get callType => JniCallType.shortType;

  @override
  String get signature => "S";
}

abstract class jint extends JPrimitive {
  static const type = jintType();
}

class jintType extends JType<jint> {
  const jintType();

  @override
  int get callType => JniCallType.intType;

  @override
  String get signature => "I";
}

abstract class jlong extends JPrimitive {
  static const type = jlongType();
}

class jlongType extends JType<jlong> {
  const jlongType();

  @override
  int get callType => JniCallType.longType;

  @override
  String get signature => "J";
}

abstract class jfloat extends JPrimitive {
  static const type = jfloatType();
}

class jfloatType extends JType<jfloat> {
  const jfloatType();

  @override
  int get callType => JniCallType.floatType;

  @override
  String get signature => "F";
}

abstract class jdouble extends JPrimitive {
  static const type = jdoubleType();
}

class jdoubleType extends JType<jdouble> {
  const jdoubleType();

  @override
  int get callType => JniCallType.doubleType;

  @override
  String get signature => "D";
}

// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'types.dart';

abstract class JPrimitive {}

abstract class JByte extends JPrimitive {
  static const type = JByteType();
}

class JByteType extends JType<JByte> {
  const JByteType();

  @override
  int get _type => JniCallType.byteType;

  @override
  String get signature => "B";
}

abstract class JBoolean extends JPrimitive {
  static const type = JBooleanType();
}

class JBooleanType extends JType<JBoolean> {
  const JBooleanType();

  @override
  int get _type => JniCallType.booleanType;

  @override
  String get signature => "Z";
}

abstract class JChar extends JPrimitive {
  static const type = JCharType();
}

class JCharType extends JType<JChar> {
  const JCharType();

  @override
  int get _type => JniCallType.charType;

  @override
  String get signature => "C";
}

abstract class JShort extends JPrimitive {
  static const type = JShortType();
}

class JShortType extends JType<JShort> {
  const JShortType();

  @override
  int get _type => JniCallType.shortType;

  @override
  String get signature => "S";
}

abstract class JInt extends JPrimitive {
  static const type = JIntType();
}

class JIntType extends JType<JInt> {
  const JIntType();

  @override
  int get _type => JniCallType.intType;

  @override
  String get signature => "I";
}

abstract class JLong extends JPrimitive {
  static const type = JLongType();
}

class JLongType extends JType<JLong> {
  const JLongType();

  @override
  int get _type => JniCallType.longType;

  @override
  String get signature => "J";
}

abstract class JFloat extends JPrimitive {
  static const type = JFloatType();
}

class JFloatType extends JType<JFloat> {
  const JFloatType();

  @override
  int get _type => JniCallType.floatType;

  @override
  String get signature => "F";
}

abstract class JDouble extends JPrimitive {
  static const type = JDoubleType();
}

class JDoubleType extends JType<JDouble> {
  const JDoubleType();

  @override
  int get _type => JniCallType.doubleType;

  @override
  String get signature => "D";
}

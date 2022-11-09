// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'types.dart';

abstract class JPrimitive {}

abstract class JByte extends JPrimitive {
  static const JType<JByte> type = _JByteTypeClass();
}

class _JByteTypeClass extends JType<JByte> {
  const _JByteTypeClass();

  @override
  int get _type => JniCallType.byteType;

  @override
  String get signature => "B";
}

abstract class JBoolean extends JPrimitive {
  static const JType<JBoolean> type = _JBooleanType();
}

class _JBooleanType extends JType<JBoolean> {
  const _JBooleanType();

  @override
  int get _type => JniCallType.booleanType;

  @override
  String get signature => "Z";
}

abstract class JChar extends JPrimitive {
  static const JType<JChar> type = _JCharType();
}

class _JCharType extends JType<JChar> {
  const _JCharType();

  @override
  int get _type => JniCallType.charType;

  @override
  String get signature => "C";
}

abstract class JShort extends JPrimitive {
  static const JType<JShort> type = _JShortType();
}

class _JShortType extends JType<JShort> {
  const _JShortType();

  @override
  int get _type => JniCallType.shortType;

  @override
  String get signature => "S";
}

abstract class JInt extends JPrimitive {
  static const JType<JInt> type = _JIntType();
}

class _JIntType extends JType<JInt> {
  const _JIntType();

  @override
  int get _type => JniCallType.intType;

  @override
  String get signature => "I";
}

abstract class JLong extends JPrimitive {
  static const JType<JLong> type = _JLongType();
}

class _JLongType extends JType<JLong> {
  const _JLongType();

  @override
  int get _type => JniCallType.longType;

  @override
  String get signature => "J";
}

abstract class JFloat extends JPrimitive {
  static const JType<JFloat> type = _JFloatType();
}

class _JFloatType extends JType<JFloat> {
  const _JFloatType();

  @override
  int get _type => JniCallType.floatType;

  @override
  String get signature => "F";
}

abstract class JDouble extends JPrimitive {
  static const JType<JDouble> type = _JDoubleType();
}

class _JDoubleType extends JType<JDouble> {
  const _JDoubleType();

  @override
  int get _type => JniCallType.doubleType;

  @override
  String get signature => "D";
}

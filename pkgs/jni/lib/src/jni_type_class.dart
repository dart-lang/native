// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'jni_object.dart';

abstract class JniType<T> {
  const JniType();

  int get _type => JniCallType.objectType;

  String get signature;

  JniClass _getClass() => Jni.findJniClass(signature);
}

class JniBooleanType extends JniType<JBoolean> {
  const JniBooleanType();

  @override
  int get _type => JniCallType.booleanType;

  @override
  String get signature => "Z";
}

class JniByteTypeClass extends JniType<JByte> {
  const JniByteTypeClass();

  @override
  int get _type => JniCallType.byteType;

  @override
  String get signature => "B";
}

class JniCharType extends JniType<JChar> {
  const JniCharType();

  @override
  int get _type => JniCallType.charType;

  @override
  String get signature => "C";
}

class JniShortType extends JniType<JShort> {
  const JniShortType();

  @override
  int get _type => JniCallType.shortType;

  @override
  String get signature => "S";
}

class JniIntType extends JniType<JInt> {
  const JniIntType();

  @override
  int get _type => JniCallType.intType;

  @override
  String get signature => "I";
}

class JniLongType extends JniType<JLong> {
  const JniLongType();

  @override
  int get _type => JniCallType.longType;

  @override
  String get signature => "J";
}

class JniFloatType extends JniType<JFloat> {
  const JniFloatType();

  @override
  int get _type => JniCallType.floatType;

  @override
  String get signature => "F";
}

class JniDoubleType extends JniType<JDouble> {
  const JniDoubleType();

  @override
  int get _type => JniCallType.doubleType;

  @override
  String get signature => "D";
}

class _JniObjectType extends JniType<JniObject> {
  const _JniObjectType();

  @override
  String get signature => "Ljava/lang/Object;";
}

class _JniStringType extends JniType<JniString> {
  const _JniStringType();

  @override
  String get signature => "Ljava/lang/String;";
}

class _JniArrayType<T> extends JniType<JniArray<T>> {
  final JniType<T> elementType;

  const _JniArrayType(this.elementType);

  @override
  String get signature => '[${elementType.signature}';
}

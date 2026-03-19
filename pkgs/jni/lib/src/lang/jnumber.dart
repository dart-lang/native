// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../core_bindings.dart' as core_bindings;
import 'jboolean.dart';
import 'jbyte.dart';
import 'jcharacter.dart';
import 'jdouble.dart';
import 'jfloat.dart';
import 'jinteger.dart';
import 'jlong.dart';
import 'jshort.dart';

export '../core_bindings.dart' show JNumber, JNumber$$Methods;

extension JNumberExtension on core_bindings.JNumber {
  /// Returns the value as a Dart int.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  int toDartByte({bool releaseOriginal = false}) {
    final ret = byteValue();
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  /// Returns the value as a Dart int.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  int toDartShort({bool releaseOriginal = false}) {
    final ret = shortValue();
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  /// Returns the value as a Dart int.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  int toDartInteger({bool releaseOriginal = false}) {
    final ret = intValue();
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  /// Returns the value as a Dart int.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  int toDartLong({bool releaseOriginal = false}) {
    final ret = longValue();
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  /// Returns the value as a Dart double.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  double toDartFloat({bool releaseOriginal = false}) {
    final ret = floatValue();
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  /// Returns the value as a Dart double.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  double toDartDouble({bool releaseOriginal = false}) {
    final ret = doubleValue();
    if (releaseOriginal) {
      release();
    }
    return ret;
  }
}

extension IntToJava on int {
  JByte toJByte() => JByte(this);
  JShort toJShort() => JShort.new$1(this);
  JInteger toJInteger() => JInteger(this);
  JLong toJLong() => JLong.new$1(this);
}

extension DoubleToJava on double {
  JFloat toJFloat() => JFloat.new$1(this);
  JDouble toJDouble() => JDouble(this);
}

extension BoolToJava on bool {
  JBoolean toJBoolean() => JBoolean(this);
}

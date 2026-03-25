// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../core_bindings.dart';

extension JNumberExtension on JNumber {
  /// Coerces the value to a JByte.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  JByte toJByte({bool releaseOriginal = false}) {
    final ret = JByte(byteValue());
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  /// Coerces the value to a JShort.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  JShort toJShort({bool releaseOriginal = false}) {
    final ret = JShort(shortValue());
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  /// Coerces the value to a JInteger.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  JInteger toJInteger({bool releaseOriginal = false}) {
    final ret = JInteger(intValue());
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  /// Coerces the value to a JLong.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  JLong toJLong({bool releaseOriginal = false}) {
    final ret = JLong(longValue());
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  /// Coerces the value to a JFloat.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  JFloat toJFloat({bool releaseOriginal = false}) {
    final ret = JFloat(floatValue());
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  /// Coerces the value to a JDouble.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  JDouble toJDouble({bool releaseOriginal = false}) {
    final ret = JDouble(doubleValue());
    if (releaseOriginal) {
      release();
    }
    return ret;
  }
}

extension IntToJava on int {
  JByte toJByte() => JByte(this);
  JShort toJShort() => JShort(this);
  JInteger toJInteger() => JInteger(this);
  JCharacter toJCharacter() => JCharacter(this);
  JLong toJLong() => JLong(this);
}

extension DoubleToJava on double {
  JFloat toJFloat() => JFloat(this);
  JDouble toJDouble() => JDouble(this);
}

extension BoolToJava on bool {
  JBoolean toJBoolean() => JBoolean(this);
}

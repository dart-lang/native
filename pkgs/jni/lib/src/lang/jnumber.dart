// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../core_bindings.dart';

/// Extension on [JNumber] providing type conversions.
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

/// Extension on [int] to convert to Java number and character types.
extension IntToJava on int {
  /// Converts this [int] to a [JByte].
  JByte toJByte() => JByte(this);

  /// Converts this [int] to a [JShort].
  JShort toJShort() => JShort(this);

  /// Converts this [int] to a [JInteger].
  JInteger toJInteger() => JInteger(this);

  /// Converts this [int] to a [JCharacter].
  JCharacter toJCharacter() => JCharacter(this);

  /// Converts this [int] to a [JLong].
  JLong toJLong() => JLong(this);
}

/// Extension on [double] to convert to Java floating point types.
extension DoubleToJava on double {
  /// Converts this [double] to a [JFloat].
  JFloat toJFloat() => JFloat(this);

  /// Converts this [double] to a [JDouble].
  JDouble toJDouble() => JDouble(this);
}

/// Extension on [bool] to convert to a [JBoolean].
extension BoolToJava on bool {
  /// Converts this [bool] to a [JBoolean].
  JBoolean toJBoolean() => JBoolean(this);
}

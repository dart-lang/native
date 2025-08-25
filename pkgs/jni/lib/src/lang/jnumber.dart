// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../jreference.dart';
import '../types.dart';
import 'jboolean.dart';
import 'jbyte.dart';
import 'jcharacter.dart';
import 'jdouble.dart';
import 'jfloat.dart';
import 'jinteger.dart';
import 'jlong.dart';
import 'jshort.dart';

@internal
final class $JNumber$NullableType$ extends JType<JNumber?> {
  const $JNumber$NullableType$();

  @override
  String get signature => r'Ljava/lang/Number;';

  @override
  JNumber? fromReference(JReference reference) =>
      reference.isNull ? null : JNumber.fromReference(reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JNumber?> get nullableType => this;

  @override
  final superCount = 1;

  @override
  int get hashCode => ($JNumber$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JNumber$NullableType$ &&
        other is $JNumber$NullableType$;
  }
}

@internal
final class $JNumber$Type$ extends JType<JNumber> {
  const $JNumber$Type$();

  @override
  String get signature => r'Ljava/lang/Number;';

  @override
  JNumber fromReference(JReference reference) =>
      JNumber.fromReference(reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JNumber?> get nullableType => const $JNumber$NullableType$();

  @override
  final superCount = 1;

  @override
  int get hashCode => ($JNumber$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JNumber$Type$ && other is $JNumber$Type$;
  }
}

class JNumber extends JObject {
  @internal
  @override
  // ignore: overridden_fields
  final JType<JNumber> $type = type;

  JNumber.fromReference(
    super.reference,
  ) : super.fromReference();

  static final _class = JClass.forName(r'java/lang/Number');

  /// The type which includes information such as the signature of this class.
  static const JType<JNumber> type = $JNumber$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JNumber?> nullableType = $JNumber$NullableType$();

  static final _ctorId = _class.constructorId(r'()V');

  JNumber() : super.fromReference(_ctorId(_class, referenceType, []));

  static final _intValueId = _class.instanceMethodId(r'intValue', r'()I');

  int intValue({bool releaseOriginal = false}) {
    final ret = _intValueId(this, const jintType(), []);
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  static final _longValueId = _class.instanceMethodId(r'longValue', r'()J');

  int longValue({bool releaseOriginal = false}) {
    final ret = _longValueId(this, const jlongType(), []);
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  static final _floatValueId = _class.instanceMethodId(r'floatValue', r'()F');

  double floatValue({bool releaseOriginal = false}) {
    final ret = _floatValueId(this, const jfloatType(), []);
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  static final _doubleValueId = _class.instanceMethodId(r'doubleValue', r'()D');

  double doubleValue({bool releaseOriginal = false}) {
    final ret = _doubleValueId(this, const jdoubleType(), []);
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  static final _byteValueId = _class.instanceMethodId(r'byteValue', r'()B');

  int byteValue({bool releaseOriginal = false}) {
    final ret = _byteValueId(this, const jbyteType(), []);
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  static final _shortValueId = _class.instanceMethodId(r'shortValue', r'()S');

  int shortValue({bool releaseOriginal = false}) {
    final ret = _shortValueId(this, const jshortType(), []);
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
  JLong toJLong() => JLong(this);
  JCharacter toJCharacter() => JCharacter(this);
}

extension DoubleToJava on double {
  JFloat toJFloat() => JFloat(this);
  JDouble toJDouble() => JDouble(this);
}

extension BoolToJava on bool {
  JBoolean toJBoolean() => JBoolean(this);
}

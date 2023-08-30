// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../accessors.dart';
import '../jni.dart';
import '../jobject.dart';
import '../jreference.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';
import 'jboolean.dart';
import 'jbyte.dart';
import 'jcharacter.dart';
import 'jdouble.dart';
import 'jfloat.dart';
import 'jinteger.dart';
import 'jlong.dart';
import 'jshort.dart';

class JNumberType extends JObjType<JNumber> {
  const JNumberType();

  @override
  String get signature => r"Ljava/lang/Number;";

  @override
  JNumber fromRef(JObjectPtr ref) => JNumber.fromRef(ref);

  @override
  JObjType get superType => const JObjectType();

  @override
  final superCount = 1;

  @override
  int get hashCode => (JNumberType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JNumberType && other is JNumberType;
  }
}

class JNumber extends JObject {
  @override
  // ignore: overridden_fields
  late final JObjType<JNumber> $type = type;

  JNumber.fromRef(
    JObjectPtr ref,
  ) : super.fromRef(ref);

  static final _class = Jni.findJClass(r"java/lang/Number");

  /// The type which includes information such as the signature of this class.
  static const type = JNumberType();
  static final _ctorId =
      Jni.accessors.getMethodIDOf(_class.reference, r"<init>", r"()V");

  JNumber()
      : super.fromRef(Jni.accessors
            .newObjectWithArgs(_class.reference, _ctorId, []).object);

  static final _intValueId =
      Jni.accessors.getMethodIDOf(_class.reference, r"intValue", r"()I");

  int intValue({bool releaseOriginal = false}) {
    ensureNotNull();
    final ret = Jni.accessors.callMethodWithArgs(
        reference, _intValueId, JniCallType.intType, []).integer;
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  static final _longValueId =
      Jni.accessors.getMethodIDOf(_class.reference, r"longValue", r"()J");

  int longValue({bool releaseOriginal = false}) {
    ensureNotNull();
    final ret = Jni.accessors.callMethodWithArgs(
        reference, _longValueId, JniCallType.longType, []).long;
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  static final _floatValueId =
      Jni.accessors.getMethodIDOf(_class.reference, r"floatValue", r"()F");

  double floatValue({bool releaseOriginal = false}) {
    ensureNotNull();
    final ret = Jni.accessors.callMethodWithArgs(
        reference, _floatValueId, JniCallType.floatType, []).float;
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  static final _doubleValueId =
      Jni.accessors.getMethodIDOf(_class.reference, r"doubleValue", r"()D");

  double doubleValue({bool releaseOriginal = false}) {
    ensureNotNull();
    final ret = Jni.accessors.callMethodWithArgs(
        reference, _doubleValueId, JniCallType.doubleType, []).doubleFloat;
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  static final _byteValueId =
      Jni.accessors.getMethodIDOf(_class.reference, r"byteValue", r"()B");

  int byteValue({bool releaseOriginal = false}) {
    ensureNotNull();
    final ret = Jni.accessors.callMethodWithArgs(
        reference, _byteValueId, JniCallType.byteType, []).byte;
    if (releaseOriginal) {
      release();
    }
    return ret;
  }

  static final _shortValueId =
      Jni.accessors.getMethodIDOf(_class.reference, r"shortValue", r"()S");

  int shortValue({bool releaseOriginal = false}) {
    ensureNotNull();
    final ret = Jni.accessors.callMethodWithArgs(
        reference, _shortValueId, JniCallType.shortType, []).short;
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

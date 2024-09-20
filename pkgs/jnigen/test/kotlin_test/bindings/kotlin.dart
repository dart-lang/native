// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Autogenerated by jnigen. DO NOT EDIT!

// ignore_for_file: annotate_overrides
// ignore_for_file: argument_type_not_assignable
// ignore_for_file: camel_case_extensions
// ignore_for_file: camel_case_types
// ignore_for_file: constant_identifier_names
// ignore_for_file: doc_directive_unknown
// ignore_for_file: file_names
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: no_leading_underscores_for_local_identifiers
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: only_throw_errors
// ignore_for_file: overridden_fields
// ignore_for_file: prefer_double_quotes
// ignore_for_file: unintended_html_in_doc_comment
// ignore_for_file: unnecessary_cast
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: unused_element
// ignore_for_file: unused_field
// ignore_for_file: unused_import
// ignore_for_file: unused_local_variable
// ignore_for_file: unused_shown_name
// ignore_for_file: use_super_parameters

import 'dart:ffi' as ffi;
import 'dart:isolate' show ReceivePort;

import 'package:jni/_internal.dart';
import 'package:jni/jni.dart' as jni;

/// from: `com.github.dart_lang.jnigen.Measure`
class Measure<$T extends jni.JObject> extends jni.JObject {
  @override
  late final jni.JObjType<Measure<$T>> $type = type(T);

  final jni.JObjType<$T> T;

  Measure.fromReference(
    this.T,
    jni.JReference reference,
  ) : super.fromReference(reference);

  static final _class =
      jni.JClass.forName(r'com/github/dart_lang/jnigen/Measure');

  /// The type which includes information such as the signature of this class.
  static $MeasureType<$T> type<$T extends jni.JObject>(
    jni.JObjType<$T> T,
  ) {
    return $MeasureType(
      T,
    );
  }

  static final _id_getValue = _class.instanceMethodId(
    r'getValue',
    r'()F',
  );

  static final _getValue = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_CallFloatMethod')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public float getValue()`
  double getValue() {
    return _getValue(reference.pointer, _id_getValue as jni.JMethodIDPtr).float;
  }

  static final _id_getUnit = _class.instanceMethodId(
    r'getUnit',
    r'()Lcom/github/dart_lang/jnigen/MeasureUnit;',
  );

  static final _getUnit = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_CallObjectMethod')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public T getUnit()`
  /// The returned object must be released after use, by calling the [release] method.
  $T getUnit() {
    return _getUnit(reference.pointer, _id_getUnit as jni.JMethodIDPtr)
        .object(T);
  }

  static final _id_convertValue = _class.instanceMethodId(
    r'convertValue',
    r'(Lcom/github/dart_lang/jnigen/MeasureUnit;)F',
  );

  static final _convertValue = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JniResult Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          'globalEnv_CallFloatMethod')
      .asFunction<
          jni.JniResult Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: `public final float convertValue(T measureUnit)`
  double convertValue(
    $T measureUnit,
  ) {
    return _convertValue(reference.pointer,
            _id_convertValue as jni.JMethodIDPtr, measureUnit.reference.pointer)
        .float;
  }
}

final class $MeasureType<$T extends jni.JObject>
    extends jni.JObjType<Measure<$T>> {
  final jni.JObjType<$T> T;

  const $MeasureType(
    this.T,
  );

  @override
  String get signature => r'Lcom/github/dart_lang/jnigen/Measure;';

  @override
  Measure<$T> fromReference(jni.JReference reference) =>
      Measure.fromReference(T, reference);

  @override
  jni.JObjType get superType => const jni.JObjectType();

  @override
  final superCount = 1;

  @override
  int get hashCode => Object.hash($MeasureType, T);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($MeasureType<$T>) &&
        other is $MeasureType<$T> &&
        T == other.T;
  }
}

/// from: `com.github.dart_lang.jnigen.MeasureUnit`
class MeasureUnit extends jni.JObject {
  @override
  late final jni.JObjType<MeasureUnit> $type = type;

  MeasureUnit.fromReference(
    jni.JReference reference,
  ) : super.fromReference(reference);

  static final _class =
      jni.JClass.forName(r'com/github/dart_lang/jnigen/MeasureUnit');

  /// The type which includes information such as the signature of this class.
  static const type = $MeasureUnitType();
  static final _id_getSign = _class.instanceMethodId(
    r'getSign',
    r'()Ljava/lang/String;',
  );

  static final _getSign = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_CallObjectMethod')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public abstract java.lang.String getSign()`
  /// The returned object must be released after use, by calling the [release] method.
  jni.JString getSign() {
    return _getSign(reference.pointer, _id_getSign as jni.JMethodIDPtr)
        .object(const jni.JStringType());
  }

  static final _id_getCoefficient = _class.instanceMethodId(
    r'getCoefficient',
    r'()F',
  );

  static final _getCoefficient = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_CallFloatMethod')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public abstract float getCoefficient()`
  double getCoefficient() {
    return _getCoefficient(
            reference.pointer, _id_getCoefficient as jni.JMethodIDPtr)
        .float;
  }
}

final class $MeasureUnitType extends jni.JObjType<MeasureUnit> {
  const $MeasureUnitType();

  @override
  String get signature => r'Lcom/github/dart_lang/jnigen/MeasureUnit;';

  @override
  MeasureUnit fromReference(jni.JReference reference) =>
      MeasureUnit.fromReference(reference);

  @override
  jni.JObjType get superType => const jni.JObjectType();

  @override
  final superCount = 1;

  @override
  int get hashCode => ($MeasureUnitType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($MeasureUnitType) && other is $MeasureUnitType;
  }
}

/// from: `com.github.dart_lang.jnigen.Speed`
class Speed extends Measure<SpeedUnit> {
  @override
  late final jni.JObjType<Speed> $type = type;

  Speed.fromReference(
    jni.JReference reference,
  ) : super.fromReference(const $SpeedUnitType(), reference);

  static final _class =
      jni.JClass.forName(r'com/github/dart_lang/jnigen/Speed');

  /// The type which includes information such as the signature of this class.
  static const type = $SpeedType();
  static final _id_new$ = _class.constructorId(
    r'(FLcom/github/dart_lang/jnigen/SpeedUnit;)V',
  );

  static final _new$ = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JniResult Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Double, ffi.Pointer<ffi.Void>)>)>>(
          'globalEnv_NewObject')
      .asFunction<
          jni.JniResult Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              double, ffi.Pointer<ffi.Void>)>();

  /// from: `public void <init>(float f, com.github.dart_lang.jnigen.SpeedUnit speedUnit)`
  /// The returned object must be released after use, by calling the [release] method.
  factory Speed(
    double f,
    SpeedUnit speedUnit,
  ) {
    return Speed.fromReference(_new$(_class.reference.pointer,
            _id_new$ as jni.JMethodIDPtr, f, speedUnit.reference.pointer)
        .reference);
  }

  static final _id_getValue = _class.instanceMethodId(
    r'getValue',
    r'()F',
  );

  static final _getValue = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_CallFloatMethod')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public float getValue()`
  double getValue() {
    return _getValue(reference.pointer, _id_getValue as jni.JMethodIDPtr).float;
  }

  static final _id_getUnit$1 = _class.instanceMethodId(
    r'getUnit',
    r'()Lcom/github/dart_lang/jnigen/SpeedUnit;',
  );

  static final _getUnit$1 = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_CallObjectMethod')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public com.github.dart_lang.jnigen.SpeedUnit getUnit()`
  /// The returned object must be released after use, by calling the [release] method.
  SpeedUnit getUnit$1() {
    return _getUnit$1(reference.pointer, _id_getUnit$1 as jni.JMethodIDPtr)
        .object(const $SpeedUnitType());
  }

  static final _id_toString$1 = _class.instanceMethodId(
    r'toString',
    r'()Ljava/lang/String;',
  );

  static final _toString$1 = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_CallObjectMethod')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public java.lang.String toString()`
  /// The returned object must be released after use, by calling the [release] method.
  jni.JString toString$1() {
    return _toString$1(reference.pointer, _id_toString$1 as jni.JMethodIDPtr)
        .object(const jni.JStringType());
  }

  static final _id_component1 = _class.instanceMethodId(
    r'component1',
    r'()F',
  );

  static final _component1 = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_CallFloatMethod')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public final float component1()`
  double component1() {
    return _component1(reference.pointer, _id_component1 as jni.JMethodIDPtr)
        .float;
  }

  static final _id_component2 = _class.instanceMethodId(
    r'component2',
    r'()Lcom/github/dart_lang/jnigen/SpeedUnit;',
  );

  static final _component2 = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_CallObjectMethod')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public final com.github.dart_lang.jnigen.SpeedUnit component2()`
  /// The returned object must be released after use, by calling the [release] method.
  SpeedUnit component2() {
    return _component2(reference.pointer, _id_component2 as jni.JMethodIDPtr)
        .object(const $SpeedUnitType());
  }

  static final _id_copy = _class.instanceMethodId(
    r'copy',
    r'(FLcom/github/dart_lang/jnigen/SpeedUnit;)Lcom/github/dart_lang/jnigen/Speed;',
  );

  static final _copy = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JniResult Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Double, ffi.Pointer<ffi.Void>)>)>>(
          'globalEnv_CallObjectMethod')
      .asFunction<
          jni.JniResult Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              double, ffi.Pointer<ffi.Void>)>();

  /// from: `public final com.github.dart_lang.jnigen.Speed copy(float f, com.github.dart_lang.jnigen.SpeedUnit speedUnit)`
  /// The returned object must be released after use, by calling the [release] method.
  Speed copy(
    double f,
    SpeedUnit speedUnit,
  ) {
    return _copy(reference.pointer, _id_copy as jni.JMethodIDPtr, f,
            speedUnit.reference.pointer)
        .object(const $SpeedType());
  }

  static final _id_hashCode$1 = _class.instanceMethodId(
    r'hashCode',
    r'()I',
  );

  static final _hashCode$1 = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_CallIntMethod')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public int hashCode()`
  int hashCode$1() {
    return _hashCode$1(reference.pointer, _id_hashCode$1 as jni.JMethodIDPtr)
        .integer;
  }

  static final _id_equals = _class.instanceMethodId(
    r'equals',
    r'(Ljava/lang/Object;)Z',
  );

  static final _equals = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JniResult Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          'globalEnv_CallBooleanMethod')
      .asFunction<
          jni.JniResult Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: `public boolean equals(java.lang.Object object)`
  bool equals(
    jni.JObject object,
  ) {
    return _equals(reference.pointer, _id_equals as jni.JMethodIDPtr,
            object.reference.pointer)
        .boolean;
  }
}

final class $SpeedType extends jni.JObjType<Speed> {
  const $SpeedType();

  @override
  String get signature => r'Lcom/github/dart_lang/jnigen/Speed;';

  @override
  Speed fromReference(jni.JReference reference) =>
      Speed.fromReference(reference);

  @override
  jni.JObjType get superType => const $MeasureType($SpeedUnitType());

  @override
  final superCount = 2;

  @override
  int get hashCode => ($SpeedType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($SpeedType) && other is $SpeedType;
  }
}

/// from: `com.github.dart_lang.jnigen.SpeedUnit`
class SpeedUnit extends jni.JObject {
  @override
  late final jni.JObjType<SpeedUnit> $type = type;

  SpeedUnit.fromReference(
    jni.JReference reference,
  ) : super.fromReference(reference);

  static final _class =
      jni.JClass.forName(r'com/github/dart_lang/jnigen/SpeedUnit');

  /// The type which includes information such as the signature of this class.
  static const type = $SpeedUnitType();
  static final _id_KmPerHour = _class.staticFieldId(
    r'KmPerHour',
    r'Lcom/github/dart_lang/jnigen/SpeedUnit;',
  );

  /// from: `static public final com.github.dart_lang.jnigen.SpeedUnit KmPerHour`
  /// The returned object must be released after use, by calling the [release] method.
  static SpeedUnit get KmPerHour =>
      _id_KmPerHour.get(_class, const $SpeedUnitType());

  static final _id_MetrePerSec = _class.staticFieldId(
    r'MetrePerSec',
    r'Lcom/github/dart_lang/jnigen/SpeedUnit;',
  );

  /// from: `static public final com.github.dart_lang.jnigen.SpeedUnit MetrePerSec`
  /// The returned object must be released after use, by calling the [release] method.
  static SpeedUnit get MetrePerSec =>
      _id_MetrePerSec.get(_class, const $SpeedUnitType());

  static final _id_getSign = _class.instanceMethodId(
    r'getSign',
    r'()Ljava/lang/String;',
  );

  static final _getSign = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_CallObjectMethod')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public java.lang.String getSign()`
  /// The returned object must be released after use, by calling the [release] method.
  jni.JString getSign() {
    return _getSign(reference.pointer, _id_getSign as jni.JMethodIDPtr)
        .object(const jni.JStringType());
  }

  static final _id_getCoefficient = _class.instanceMethodId(
    r'getCoefficient',
    r'()F',
  );

  static final _getCoefficient = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_CallFloatMethod')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public float getCoefficient()`
  double getCoefficient() {
    return _getCoefficient(
            reference.pointer, _id_getCoefficient as jni.JMethodIDPtr)
        .float;
  }

  static final _id_values = _class.staticMethodId(
    r'values',
    r'()[Lcom/github/dart_lang/jnigen/SpeedUnit;',
  );

  static final _values = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_CallStaticObjectMethod')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `static public com.github.dart_lang.jnigen.SpeedUnit[] values()`
  /// The returned object must be released after use, by calling the [release] method.
  static jni.JArray<SpeedUnit> values() {
    return _values(_class.reference.pointer, _id_values as jni.JMethodIDPtr)
        .object(const jni.JArrayType($SpeedUnitType()));
  }

  static final _id_valueOf = _class.staticMethodId(
    r'valueOf',
    r'(Ljava/lang/String;)Lcom/github/dart_lang/jnigen/SpeedUnit;',
  );

  static final _valueOf = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JniResult Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          'globalEnv_CallStaticObjectMethod')
      .asFunction<
          jni.JniResult Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: `static public com.github.dart_lang.jnigen.SpeedUnit valueOf(java.lang.String string)`
  /// The returned object must be released after use, by calling the [release] method.
  static SpeedUnit valueOf(
    jni.JString string,
  ) {
    return _valueOf(_class.reference.pointer, _id_valueOf as jni.JMethodIDPtr,
            string.reference.pointer)
        .object(const $SpeedUnitType());
  }
}

final class $SpeedUnitType extends jni.JObjType<SpeedUnit> {
  const $SpeedUnitType();

  @override
  String get signature => r'Lcom/github/dart_lang/jnigen/SpeedUnit;';

  @override
  SpeedUnit fromReference(jni.JReference reference) =>
      SpeedUnit.fromReference(reference);

  @override
  jni.JObjType get superType => const jni.JObjectType();

  @override
  final superCount = 1;

  @override
  int get hashCode => ($SpeedUnitType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($SpeedUnitType) && other is $SpeedUnitType;
  }
}

/// from: `com.github.dart_lang.jnigen.SuspendFun`
class SuspendFun extends jni.JObject {
  @override
  late final jni.JObjType<SuspendFun> $type = type;

  SuspendFun.fromReference(
    jni.JReference reference,
  ) : super.fromReference(reference);

  static final _class =
      jni.JClass.forName(r'com/github/dart_lang/jnigen/SuspendFun');

  /// The type which includes information such as the signature of this class.
  static const type = $SuspendFunType();
  static final _id_new$ = _class.constructorId(
    r'()V',
  );

  static final _new$ = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_NewObject')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public void <init>()`
  /// The returned object must be released after use, by calling the [release] method.
  factory SuspendFun() {
    return SuspendFun.fromReference(
        _new$(_class.reference.pointer, _id_new$ as jni.JMethodIDPtr)
            .reference);
  }

  static final _id_sayHello = _class.instanceMethodId(
    r'sayHello',
    r'(Lkotlin/coroutines/Continuation;)Ljava/lang/Object;',
  );

  static final _sayHello = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JniResult Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          'globalEnv_CallObjectMethod')
      .asFunction<
          jni.JniResult Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: `public final java.lang.Object sayHello(kotlin.coroutines.Continuation continuation)`
  /// The returned object must be released after use, by calling the [release] method.
  Future<jni.JString> sayHello() async {
    final $p = ReceivePort();
    final $c = jni.JObject.fromReference(
        ProtectedJniExtensions.newPortContinuation($p));
    _sayHello(reference.pointer, _id_sayHello as jni.JMethodIDPtr,
            $c.reference.pointer)
        .object(const jni.JObjectType());
    final $o = jni.JGlobalReference(jni.JObjectPtr.fromAddress(await $p.first));
    final $k = const jni.JStringType().jClass.reference.pointer;
    if (!jni.Jni.env.IsInstanceOf($o.pointer, $k)) {
      throw 'Failed';
    }
    return const jni.JStringType().fromReference($o);
  }

  static final _id_sayHello$1 = _class.instanceMethodId(
    r'sayHello',
    r'(Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;',
  );

  static final _sayHello$1 = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                  ffi.Pointer<ffi.Void>,
                  jni.JMethodIDPtr,
                  ffi.VarArgs<
                      (
                        ffi.Pointer<ffi.Void>,
                        ffi.Pointer<ffi.Void>
                      )>)>>('globalEnv_CallObjectMethod')
      .asFunction<
          jni.JniResult Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Void>)>();

  /// from: `public final java.lang.Object sayHello(java.lang.String string, kotlin.coroutines.Continuation continuation)`
  /// The returned object must be released after use, by calling the [release] method.
  Future<jni.JString> sayHello$1(
    jni.JString string,
  ) async {
    final $p = ReceivePort();
    final $c = jni.JObject.fromReference(
        ProtectedJniExtensions.newPortContinuation($p));
    _sayHello$1(reference.pointer, _id_sayHello$1 as jni.JMethodIDPtr,
            string.reference.pointer, $c.reference.pointer)
        .object(const jni.JObjectType());
    final $o = jni.JGlobalReference(jni.JObjectPtr.fromAddress(await $p.first));
    final $k = const jni.JStringType().jClass.reference.pointer;
    if (!jni.Jni.env.IsInstanceOf($o.pointer, $k)) {
      throw 'Failed';
    }
    return const jni.JStringType().fromReference($o);
  }
}

final class $SuspendFunType extends jni.JObjType<SuspendFun> {
  const $SuspendFunType();

  @override
  String get signature => r'Lcom/github/dart_lang/jnigen/SuspendFun;';

  @override
  SuspendFun fromReference(jni.JReference reference) =>
      SuspendFun.fromReference(reference);

  @override
  jni.JObjType get superType => const jni.JObjectType();

  @override
  final superCount = 1;

  @override
  int get hashCode => ($SuspendFunType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($SuspendFunType) && other is $SuspendFunType;
  }
}

final _TopLevelKtClass =
    jni.JClass.forName(r'com/github/dart_lang/jnigen/TopLevelKt');

final _id_getTopLevelField = _TopLevelKtClass.staticMethodId(
  r'getTopLevelField',
  r'()I',
);

final _getTopLevelField = ProtectedJniExtensions.lookup<
        ffi.NativeFunction<
            jni.JniResult Function(
              ffi.Pointer<ffi.Void>,
              jni.JMethodIDPtr,
            )>>('globalEnv_CallStaticIntMethod')
    .asFunction<
        jni.JniResult Function(
          ffi.Pointer<ffi.Void>,
          jni.JMethodIDPtr,
        )>();

/// from: `static public final int getTopLevelField()`
int getTopLevelField() {
  return _getTopLevelField(_TopLevelKtClass.reference.pointer,
          _id_getTopLevelField as jni.JMethodIDPtr)
      .integer;
}

final _id_setTopLevelField = _TopLevelKtClass.staticMethodId(
  r'setTopLevelField',
  r'(I)V',
);

final _setTopLevelField = ProtectedJniExtensions.lookup<
        ffi.NativeFunction<
            jni.JThrowablePtr Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
                ffi.VarArgs<($Int32,)>)>>('globalEnv_CallStaticVoidMethod')
    .asFunction<
        jni.JThrowablePtr Function(
            ffi.Pointer<ffi.Void>, jni.JMethodIDPtr, int)>();

/// from: `static public final void setTopLevelField(int i)`
void setTopLevelField(
  int i,
) {
  _setTopLevelField(_TopLevelKtClass.reference.pointer,
          _id_setTopLevelField as jni.JMethodIDPtr, i)
      .check();
}

final _id_topLevel = _TopLevelKtClass.staticMethodId(
  r'topLevel',
  r'()I',
);

final _topLevel = ProtectedJniExtensions.lookup<
        ffi.NativeFunction<
            jni.JniResult Function(
              ffi.Pointer<ffi.Void>,
              jni.JMethodIDPtr,
            )>>('globalEnv_CallStaticIntMethod')
    .asFunction<
        jni.JniResult Function(
          ffi.Pointer<ffi.Void>,
          jni.JMethodIDPtr,
        )>();

/// from: `static public final int topLevel()`
int topLevel() {
  return _topLevel(
          _TopLevelKtClass.reference.pointer, _id_topLevel as jni.JMethodIDPtr)
      .integer;
}

final _id_topLevelSum = _TopLevelKtClass.staticMethodId(
  r'topLevelSum',
  r'(II)I',
);

final _topLevelSum = ProtectedJniExtensions.lookup<
            ffi.NativeFunction<
                jni.JniResult Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
                    ffi.VarArgs<($Int32, $Int32)>)>>(
        'globalEnv_CallStaticIntMethod')
    .asFunction<
        jni.JniResult Function(
            ffi.Pointer<ffi.Void>, jni.JMethodIDPtr, int, int)>();

/// from: `static public final int topLevelSum(int i, int i1)`
int topLevelSum(
  int i,
  int i1,
) {
  return _topLevelSum(_TopLevelKtClass.reference.pointer,
          _id_topLevelSum as jni.JMethodIDPtr, i, i1)
      .integer;
}

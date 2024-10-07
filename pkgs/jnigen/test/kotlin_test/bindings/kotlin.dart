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
// ignore_for_file: inference_failure_on_untyped_parameter
// ignore_for_file: invalid_internal_annotation
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: library_prefixes
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: no_leading_underscores_for_library_prefixes
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

import 'dart:core' show Object, String, bool, double, int;
import 'dart:core' as _$core;

import 'package:jni/_internal.dart' as _$jni;
import 'package:jni/jni.dart' as _$jni;

/// from: `com.github.dart_lang.jnigen.Measure`
class Measure<$T extends _$jni.JObject> extends _$jni.JObject {
  @_$jni.internal
  @_$core.override
  final _$jni.JObjType<Measure<$T>> $type;

  @_$jni.internal
  final _$jni.JObjType<$T> T;

  @_$jni.internal
  Measure.fromReference(
    this.T,
    _$jni.JReference reference,
  )   : $type = type(T),
        super.fromReference(reference);

  static final _class =
      _$jni.JClass.forName(r'com/github/dart_lang/jnigen/Measure');

  /// The type which includes information such as the signature of this class.
  static $Measure$Type<$T> type<$T extends _$jni.JObject>(
    _$jni.JObjType<$T> T,
  ) {
    return $Measure$Type(
      T,
    );
  }

  static final _id_getValue = _class.instanceMethodId(
    r'getValue',
    r'()F',
  );

  static final _getValue = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_CallFloatMethod')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public float getValue()`
  double getValue() {
    return _getValue(reference.pointer, _id_getValue as _$jni.JMethodIDPtr)
        .float;
  }

  static final _id_getUnit = _class.instanceMethodId(
    r'getUnit',
    r'()Lcom/github/dart_lang/jnigen/MeasureUnit;',
  );

  static final _getUnit = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_CallObjectMethod')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public T getUnit()`
  /// The returned object must be released after use, by calling the [release] method.
  $T getUnit() {
    return _getUnit(reference.pointer, _id_getUnit as _$jni.JMethodIDPtr)
        .object(T);
  }

  static final _id_convertValue = _class.instanceMethodId(
    r'convertValue',
    r'(Lcom/github/dart_lang/jnigen/MeasureUnit;)F',
  );

  static final _convertValue = _$jni.ProtectedJniExtensions.lookup<
              _$jni.NativeFunction<
                  _$jni.JniResult Function(
                      _$jni.Pointer<_$jni.Void>,
                      _$jni.JMethodIDPtr,
                      _$jni.VarArgs<(_$jni.Pointer<_$jni.Void>,)>)>>(
          'globalEnv_CallFloatMethod')
      .asFunction<
          _$jni.JniResult Function(_$jni.Pointer<_$jni.Void>,
              _$jni.JMethodIDPtr, _$jni.Pointer<_$jni.Void>)>();

  /// from: `public final float convertValue(T measureUnit)`
  double convertValue(
    $T measureUnit,
  ) {
    return _convertValue(
            reference.pointer,
            _id_convertValue as _$jni.JMethodIDPtr,
            measureUnit.reference.pointer)
        .float;
  }
}

final class $Measure$Type<$T extends _$jni.JObject>
    extends _$jni.JObjType<Measure<$T>> {
  @_$jni.internal
  final _$jni.JObjType<$T> T;

  @_$jni.internal
  const $Measure$Type(
    this.T,
  );

  @_$jni.internal
  @_$core.override
  String get signature => r'Lcom/github/dart_lang/jnigen/Measure;';

  @_$jni.internal
  @_$core.override
  Measure<$T> fromReference(_$jni.JReference reference) =>
      Measure.fromReference(T, reference);

  @_$jni.internal
  @_$core.override
  _$jni.JObjType get superType => const _$jni.JObjectType();

  @_$jni.internal
  @_$core.override
  final superCount = 1;

  @_$core.override
  int get hashCode => Object.hash($Measure$Type, T);

  @_$core.override
  bool operator ==(Object other) {
    return other.runtimeType == ($Measure$Type<$T>) &&
        other is $Measure$Type<$T> &&
        T == other.T;
  }
}

/// from: `com.github.dart_lang.jnigen.MeasureUnit`
class MeasureUnit extends _$jni.JObject {
  @_$jni.internal
  @_$core.override
  final _$jni.JObjType<MeasureUnit> $type;

  @_$jni.internal
  MeasureUnit.fromReference(
    _$jni.JReference reference,
  )   : $type = type,
        super.fromReference(reference);

  static final _class =
      _$jni.JClass.forName(r'com/github/dart_lang/jnigen/MeasureUnit');

  /// The type which includes information such as the signature of this class.
  static const type = $MeasureUnit$Type();
  static final _id_getSign = _class.instanceMethodId(
    r'getSign',
    r'()Ljava/lang/String;',
  );

  static final _getSign = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_CallObjectMethod')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public abstract java.lang.String getSign()`
  /// The returned object must be released after use, by calling the [release] method.
  _$jni.JString getSign() {
    return _getSign(reference.pointer, _id_getSign as _$jni.JMethodIDPtr)
        .object(const _$jni.JStringType());
  }

  static final _id_getCoefficient = _class.instanceMethodId(
    r'getCoefficient',
    r'()F',
  );

  static final _getCoefficient = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_CallFloatMethod')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public abstract float getCoefficient()`
  double getCoefficient() {
    return _getCoefficient(
            reference.pointer, _id_getCoefficient as _$jni.JMethodIDPtr)
        .float;
  }

  /// Maps a specific port to the implemented interface.
  static final _$core.Map<int, $MeasureUnit> _$impls = {};
  static _$jni.JObjectPtr _$invoke(
    int port,
    _$jni.JObjectPtr descriptor,
    _$jni.JObjectPtr args,
  ) {
    return _$invokeMethod(
      port,
      _$jni.MethodInvocation.fromAddresses(
        0,
        descriptor.address,
        args.address,
      ),
    );
  }

  static final _$jni.Pointer<
          _$jni.NativeFunction<
              _$jni.JObjectPtr Function(
                  _$jni.Int64, _$jni.JObjectPtr, _$jni.JObjectPtr)>>
      _$invokePointer = _$jni.Pointer.fromFunction(_$invoke);

  static _$jni.Pointer<_$jni.Void> _$invokeMethod(
    int $p,
    _$jni.MethodInvocation $i,
  ) {
    try {
      final $d = $i.methodDescriptor.toDartString(releaseOriginal: true);
      final $a = $i.args;
      if ($d == r'getSign()Ljava/lang/String;') {
        final $r = _$impls[$p]!.getSign();
        return ($r as _$jni.JObject)
            .as(const _$jni.JObjectType())
            .reference
            .toPointer();
      }
      if ($d == r'getCoefficient()F') {
        final $r = _$impls[$p]!.getCoefficient();
        return _$jni.JFloat($r).reference.toPointer();
      }
    } catch (e) {
      return _$jni.ProtectedJniExtensions.newDartException(e);
    }
    return _$jni.nullptr;
  }

  static void implementIn(
    _$jni.JImplementer implementer,
    $MeasureUnit $impl,
  ) {
    late final _$jni.RawReceivePort $p;
    $p = _$jni.RawReceivePort(($m) {
      if ($m == null) {
        _$impls.remove($p.sendPort.nativePort);
        $p.close();
        return;
      }
      final $i = _$jni.MethodInvocation.fromMessage($m);
      final $r = _$invokeMethod($p.sendPort.nativePort, $i);
      _$jni.ProtectedJniExtensions.returnResult($i.result, $r);
    });
    implementer.add(
      r'com.github.dart_lang.jnigen.MeasureUnit',
      $p,
      _$invokePointer,
      [],
    );
    final $a = $p.sendPort.nativePort;
    _$impls[$a] = $impl;
  }

  factory MeasureUnit.implement(
    $MeasureUnit $impl,
  ) {
    final $i = _$jni.JImplementer();
    implementIn($i, $impl);
    return MeasureUnit.fromReference(
      $i.implementReference(),
    );
  }
}

abstract base mixin class $MeasureUnit {
  factory $MeasureUnit({
    required _$jni.JString Function() getSign,
    required double Function() getCoefficient,
  }) = _$MeasureUnit;

  _$jni.JString getSign();
  double getCoefficient();
}

final class _$MeasureUnit with $MeasureUnit {
  _$MeasureUnit({
    required _$jni.JString Function() getSign,
    required double Function() getCoefficient,
  })  : _getSign = getSign,
        _getCoefficient = getCoefficient;

  final _$jni.JString Function() _getSign;
  final double Function() _getCoefficient;

  _$jni.JString getSign() {
    return _getSign();
  }

  double getCoefficient() {
    return _getCoefficient();
  }
}

final class $MeasureUnit$Type extends _$jni.JObjType<MeasureUnit> {
  @_$jni.internal
  const $MeasureUnit$Type();

  @_$jni.internal
  @_$core.override
  String get signature => r'Lcom/github/dart_lang/jnigen/MeasureUnit;';

  @_$jni.internal
  @_$core.override
  MeasureUnit fromReference(_$jni.JReference reference) =>
      MeasureUnit.fromReference(reference);

  @_$jni.internal
  @_$core.override
  _$jni.JObjType get superType => const _$jni.JObjectType();

  @_$jni.internal
  @_$core.override
  final superCount = 1;

  @_$core.override
  int get hashCode => ($MeasureUnit$Type).hashCode;

  @_$core.override
  bool operator ==(Object other) {
    return other.runtimeType == ($MeasureUnit$Type) &&
        other is $MeasureUnit$Type;
  }
}

/// from: `com.github.dart_lang.jnigen.Speed`
class Speed extends Measure<SpeedUnit> {
  @_$jni.internal
  @_$core.override
  final _$jni.JObjType<Speed> $type;

  @_$jni.internal
  Speed.fromReference(
    _$jni.JReference reference,
  )   : $type = type,
        super.fromReference(const $SpeedUnit$Type(), reference);

  static final _class =
      _$jni.JClass.forName(r'com/github/dart_lang/jnigen/Speed');

  /// The type which includes information such as the signature of this class.
  static const type = $Speed$Type();
  static final _id_new$ = _class.constructorId(
    r'(FLcom/github/dart_lang/jnigen/SpeedUnit;)V',
  );

  static final _new$ = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                  _$jni.Pointer<_$jni.Void>,
                  _$jni.JMethodIDPtr,
                  _$jni.VarArgs<
                      (
                        _$jni.Double,
                        _$jni.Pointer<_$jni.Void>
                      )>)>>('globalEnv_NewObject')
      .asFunction<
          _$jni.JniResult Function(_$jni.Pointer<_$jni.Void>,
              _$jni.JMethodIDPtr, double, _$jni.Pointer<_$jni.Void>)>();

  /// from: `public void <init>(float f, com.github.dart_lang.jnigen.SpeedUnit speedUnit)`
  /// The returned object must be released after use, by calling the [release] method.
  factory Speed(
    double f,
    SpeedUnit speedUnit,
  ) {
    return Speed.fromReference(_new$(_class.reference.pointer,
            _id_new$ as _$jni.JMethodIDPtr, f, speedUnit.reference.pointer)
        .reference);
  }

  static final _id_getValue = _class.instanceMethodId(
    r'getValue',
    r'()F',
  );

  static final _getValue = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_CallFloatMethod')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public float getValue()`
  double getValue() {
    return _getValue(reference.pointer, _id_getValue as _$jni.JMethodIDPtr)
        .float;
  }

  static final _id_getUnit$1 = _class.instanceMethodId(
    r'getUnit',
    r'()Lcom/github/dart_lang/jnigen/SpeedUnit;',
  );

  static final _getUnit$1 = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_CallObjectMethod')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public com.github.dart_lang.jnigen.SpeedUnit getUnit()`
  /// The returned object must be released after use, by calling the [release] method.
  SpeedUnit getUnit$1() {
    return _getUnit$1(reference.pointer, _id_getUnit$1 as _$jni.JMethodIDPtr)
        .object(const $SpeedUnit$Type());
  }

  static final _id_toString$1 = _class.instanceMethodId(
    r'toString',
    r'()Ljava/lang/String;',
  );

  static final _toString$1 = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_CallObjectMethod')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public java.lang.String toString()`
  /// The returned object must be released after use, by calling the [release] method.
  _$jni.JString toString$1() {
    return _toString$1(reference.pointer, _id_toString$1 as _$jni.JMethodIDPtr)
        .object(const _$jni.JStringType());
  }

  static final _id_component1 = _class.instanceMethodId(
    r'component1',
    r'()F',
  );

  static final _component1 = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_CallFloatMethod')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public final float component1()`
  double component1() {
    return _component1(reference.pointer, _id_component1 as _$jni.JMethodIDPtr)
        .float;
  }

  static final _id_component2 = _class.instanceMethodId(
    r'component2',
    r'()Lcom/github/dart_lang/jnigen/SpeedUnit;',
  );

  static final _component2 = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_CallObjectMethod')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public final com.github.dart_lang.jnigen.SpeedUnit component2()`
  /// The returned object must be released after use, by calling the [release] method.
  SpeedUnit component2() {
    return _component2(reference.pointer, _id_component2 as _$jni.JMethodIDPtr)
        .object(const $SpeedUnit$Type());
  }

  static final _id_copy = _class.instanceMethodId(
    r'copy',
    r'(FLcom/github/dart_lang/jnigen/SpeedUnit;)Lcom/github/dart_lang/jnigen/Speed;',
  );

  static final _copy = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                  _$jni.Pointer<_$jni.Void>,
                  _$jni.JMethodIDPtr,
                  _$jni.VarArgs<
                      (
                        _$jni.Double,
                        _$jni.Pointer<_$jni.Void>
                      )>)>>('globalEnv_CallObjectMethod')
      .asFunction<
          _$jni.JniResult Function(_$jni.Pointer<_$jni.Void>,
              _$jni.JMethodIDPtr, double, _$jni.Pointer<_$jni.Void>)>();

  /// from: `public final com.github.dart_lang.jnigen.Speed copy(float f, com.github.dart_lang.jnigen.SpeedUnit speedUnit)`
  /// The returned object must be released after use, by calling the [release] method.
  Speed copy(
    double f,
    SpeedUnit speedUnit,
  ) {
    return _copy(reference.pointer, _id_copy as _$jni.JMethodIDPtr, f,
            speedUnit.reference.pointer)
        .object(const $Speed$Type());
  }

  static final _id_hashCode$1 = _class.instanceMethodId(
    r'hashCode',
    r'()I',
  );

  static final _hashCode$1 = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_CallIntMethod')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public int hashCode()`
  int hashCode$1() {
    return _hashCode$1(reference.pointer, _id_hashCode$1 as _$jni.JMethodIDPtr)
        .integer;
  }

  static final _id_equals = _class.instanceMethodId(
    r'equals',
    r'(Ljava/lang/Object;)Z',
  );

  static final _equals = _$jni.ProtectedJniExtensions.lookup<
              _$jni.NativeFunction<
                  _$jni.JniResult Function(
                      _$jni.Pointer<_$jni.Void>,
                      _$jni.JMethodIDPtr,
                      _$jni.VarArgs<(_$jni.Pointer<_$jni.Void>,)>)>>(
          'globalEnv_CallBooleanMethod')
      .asFunction<
          _$jni.JniResult Function(_$jni.Pointer<_$jni.Void>,
              _$jni.JMethodIDPtr, _$jni.Pointer<_$jni.Void>)>();

  /// from: `public boolean equals(java.lang.Object object)`
  bool equals(
    _$jni.JObject object,
  ) {
    return _equals(reference.pointer, _id_equals as _$jni.JMethodIDPtr,
            object.reference.pointer)
        .boolean;
  }
}

final class $Speed$Type extends _$jni.JObjType<Speed> {
  @_$jni.internal
  const $Speed$Type();

  @_$jni.internal
  @_$core.override
  String get signature => r'Lcom/github/dart_lang/jnigen/Speed;';

  @_$jni.internal
  @_$core.override
  Speed fromReference(_$jni.JReference reference) =>
      Speed.fromReference(reference);

  @_$jni.internal
  @_$core.override
  _$jni.JObjType get superType => const $Measure$Type($SpeedUnit$Type());

  @_$jni.internal
  @_$core.override
  final superCount = 2;

  @_$core.override
  int get hashCode => ($Speed$Type).hashCode;

  @_$core.override
  bool operator ==(Object other) {
    return other.runtimeType == ($Speed$Type) && other is $Speed$Type;
  }
}

/// from: `com.github.dart_lang.jnigen.SpeedUnit`
class SpeedUnit extends _$jni.JObject {
  @_$jni.internal
  @_$core.override
  final _$jni.JObjType<SpeedUnit> $type;

  @_$jni.internal
  SpeedUnit.fromReference(
    _$jni.JReference reference,
  )   : $type = type,
        super.fromReference(reference);

  static final _class =
      _$jni.JClass.forName(r'com/github/dart_lang/jnigen/SpeedUnit');

  /// The type which includes information such as the signature of this class.
  static const type = $SpeedUnit$Type();
  static final _id_KmPerHour = _class.staticFieldId(
    r'KmPerHour',
    r'Lcom/github/dart_lang/jnigen/SpeedUnit;',
  );

  /// from: `static public final com.github.dart_lang.jnigen.SpeedUnit KmPerHour`
  /// The returned object must be released after use, by calling the [release] method.
  static SpeedUnit get KmPerHour =>
      _id_KmPerHour.get(_class, const $SpeedUnit$Type());

  static final _id_MetrePerSec = _class.staticFieldId(
    r'MetrePerSec',
    r'Lcom/github/dart_lang/jnigen/SpeedUnit;',
  );

  /// from: `static public final com.github.dart_lang.jnigen.SpeedUnit MetrePerSec`
  /// The returned object must be released after use, by calling the [release] method.
  static SpeedUnit get MetrePerSec =>
      _id_MetrePerSec.get(_class, const $SpeedUnit$Type());

  static final _id_getSign = _class.instanceMethodId(
    r'getSign',
    r'()Ljava/lang/String;',
  );

  static final _getSign = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_CallObjectMethod')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public java.lang.String getSign()`
  /// The returned object must be released after use, by calling the [release] method.
  _$jni.JString getSign() {
    return _getSign(reference.pointer, _id_getSign as _$jni.JMethodIDPtr)
        .object(const _$jni.JStringType());
  }

  static final _id_getCoefficient = _class.instanceMethodId(
    r'getCoefficient',
    r'()F',
  );

  static final _getCoefficient = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_CallFloatMethod')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public float getCoefficient()`
  double getCoefficient() {
    return _getCoefficient(
            reference.pointer, _id_getCoefficient as _$jni.JMethodIDPtr)
        .float;
  }

  static final _id_values = _class.staticMethodId(
    r'values',
    r'()[Lcom/github/dart_lang/jnigen/SpeedUnit;',
  );

  static final _values = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_CallStaticObjectMethod')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `static public com.github.dart_lang.jnigen.SpeedUnit[] values()`
  /// The returned object must be released after use, by calling the [release] method.
  static _$jni.JArray<SpeedUnit> values() {
    return _values(_class.reference.pointer, _id_values as _$jni.JMethodIDPtr)
        .object(const _$jni.JArrayType($SpeedUnit$Type()));
  }

  static final _id_valueOf = _class.staticMethodId(
    r'valueOf',
    r'(Ljava/lang/String;)Lcom/github/dart_lang/jnigen/SpeedUnit;',
  );

  static final _valueOf = _$jni.ProtectedJniExtensions.lookup<
              _$jni.NativeFunction<
                  _$jni.JniResult Function(
                      _$jni.Pointer<_$jni.Void>,
                      _$jni.JMethodIDPtr,
                      _$jni.VarArgs<(_$jni.Pointer<_$jni.Void>,)>)>>(
          'globalEnv_CallStaticObjectMethod')
      .asFunction<
          _$jni.JniResult Function(_$jni.Pointer<_$jni.Void>,
              _$jni.JMethodIDPtr, _$jni.Pointer<_$jni.Void>)>();

  /// from: `static public com.github.dart_lang.jnigen.SpeedUnit valueOf(java.lang.String string)`
  /// The returned object must be released after use, by calling the [release] method.
  static SpeedUnit valueOf(
    _$jni.JString string,
  ) {
    return _valueOf(_class.reference.pointer, _id_valueOf as _$jni.JMethodIDPtr,
            string.reference.pointer)
        .object(const $SpeedUnit$Type());
  }
}

final class $SpeedUnit$Type extends _$jni.JObjType<SpeedUnit> {
  @_$jni.internal
  const $SpeedUnit$Type();

  @_$jni.internal
  @_$core.override
  String get signature => r'Lcom/github/dart_lang/jnigen/SpeedUnit;';

  @_$jni.internal
  @_$core.override
  SpeedUnit fromReference(_$jni.JReference reference) =>
      SpeedUnit.fromReference(reference);

  @_$jni.internal
  @_$core.override
  _$jni.JObjType get superType => const _$jni.JObjectType();

  @_$jni.internal
  @_$core.override
  final superCount = 1;

  @_$core.override
  int get hashCode => ($SpeedUnit$Type).hashCode;

  @_$core.override
  bool operator ==(Object other) {
    return other.runtimeType == ($SpeedUnit$Type) && other is $SpeedUnit$Type;
  }
}

/// from: `com.github.dart_lang.jnigen.SuspendFun`
class SuspendFun extends _$jni.JObject {
  @_$jni.internal
  @_$core.override
  final _$jni.JObjType<SuspendFun> $type;

  @_$jni.internal
  SuspendFun.fromReference(
    _$jni.JReference reference,
  )   : $type = type,
        super.fromReference(reference);

  static final _class =
      _$jni.JClass.forName(r'com/github/dart_lang/jnigen/SuspendFun');

  /// The type which includes information such as the signature of this class.
  static const type = $SuspendFun$Type();
  static final _id_new$ = _class.constructorId(
    r'()V',
  );

  static final _new$ = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_NewObject')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public void <init>()`
  /// The returned object must be released after use, by calling the [release] method.
  factory SuspendFun() {
    return SuspendFun.fromReference(
        _new$(_class.reference.pointer, _id_new$ as _$jni.JMethodIDPtr)
            .reference);
  }

  static final _id_sayHello = _class.instanceMethodId(
    r'sayHello',
    r'(Lkotlin/coroutines/Continuation;)Ljava/lang/Object;',
  );

  static final _sayHello = _$jni.ProtectedJniExtensions.lookup<
              _$jni.NativeFunction<
                  _$jni.JniResult Function(
                      _$jni.Pointer<_$jni.Void>,
                      _$jni.JMethodIDPtr,
                      _$jni.VarArgs<(_$jni.Pointer<_$jni.Void>,)>)>>(
          'globalEnv_CallObjectMethod')
      .asFunction<
          _$jni.JniResult Function(_$jni.Pointer<_$jni.Void>,
              _$jni.JMethodIDPtr, _$jni.Pointer<_$jni.Void>)>();

  /// from: `public final java.lang.Object sayHello(kotlin.coroutines.Continuation continuation)`
  /// The returned object must be released after use, by calling the [release] method.
  _$core.Future<_$jni.JString> sayHello() async {
    final $p = _$jni.ReceivePort();
    final $c = _$jni.JObject.fromReference(
        _$jni.ProtectedJniExtensions.newPortContinuation($p));
    _sayHello(reference.pointer, _id_sayHello as _$jni.JMethodIDPtr,
            $c.reference.pointer)
        .object(const _$jni.JObjectType());
    final $o =
        _$jni.JGlobalReference(_$jni.JObjectPtr.fromAddress(await $p.first));
    final $k = const _$jni.JStringType().jClass.reference.pointer;
    if (!_$jni.Jni.env.IsInstanceOf($o.pointer, $k)) {
      throw 'Failed';
    }
    return const _$jni.JStringType().fromReference($o);
  }

  static final _id_sayHello$1 = _class.instanceMethodId(
    r'sayHello',
    r'(Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;',
  );

  static final _sayHello$1 = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                  _$jni.Pointer<_$jni.Void>,
                  _$jni.JMethodIDPtr,
                  _$jni.VarArgs<
                      (
                        _$jni.Pointer<_$jni.Void>,
                        _$jni.Pointer<_$jni.Void>
                      )>)>>('globalEnv_CallObjectMethod')
      .asFunction<
          _$jni.JniResult Function(
              _$jni.Pointer<_$jni.Void>,
              _$jni.JMethodIDPtr,
              _$jni.Pointer<_$jni.Void>,
              _$jni.Pointer<_$jni.Void>)>();

  /// from: `public final java.lang.Object sayHello(java.lang.String string, kotlin.coroutines.Continuation continuation)`
  /// The returned object must be released after use, by calling the [release] method.
  _$core.Future<_$jni.JString> sayHello$1(
    _$jni.JString string,
  ) async {
    final $p = _$jni.ReceivePort();
    final $c = _$jni.JObject.fromReference(
        _$jni.ProtectedJniExtensions.newPortContinuation($p));
    _sayHello$1(reference.pointer, _id_sayHello$1 as _$jni.JMethodIDPtr,
            string.reference.pointer, $c.reference.pointer)
        .object(const _$jni.JObjectType());
    final $o =
        _$jni.JGlobalReference(_$jni.JObjectPtr.fromAddress(await $p.first));
    final $k = const _$jni.JStringType().jClass.reference.pointer;
    if (!_$jni.Jni.env.IsInstanceOf($o.pointer, $k)) {
      throw 'Failed';
    }
    return const _$jni.JStringType().fromReference($o);
  }
}

final class $SuspendFun$Type extends _$jni.JObjType<SuspendFun> {
  @_$jni.internal
  const $SuspendFun$Type();

  @_$jni.internal
  @_$core.override
  String get signature => r'Lcom/github/dart_lang/jnigen/SuspendFun;';

  @_$jni.internal
  @_$core.override
  SuspendFun fromReference(_$jni.JReference reference) =>
      SuspendFun.fromReference(reference);

  @_$jni.internal
  @_$core.override
  _$jni.JObjType get superType => const _$jni.JObjectType();

  @_$jni.internal
  @_$core.override
  final superCount = 1;

  @_$core.override
  int get hashCode => ($SuspendFun$Type).hashCode;

  @_$core.override
  bool operator ==(Object other) {
    return other.runtimeType == ($SuspendFun$Type) && other is $SuspendFun$Type;
  }
}

final _TopLevelKtClass =
    _$jni.JClass.forName(r'com/github/dart_lang/jnigen/TopLevelKt');

final _id_getTopLevelField = _TopLevelKtClass.staticMethodId(
  r'getTopLevelField',
  r'()I',
);

final _getTopLevelField = _$jni.ProtectedJniExtensions.lookup<
        _$jni.NativeFunction<
            _$jni.JniResult Function(
              _$jni.Pointer<_$jni.Void>,
              _$jni.JMethodIDPtr,
            )>>('globalEnv_CallStaticIntMethod')
    .asFunction<
        _$jni.JniResult Function(
          _$jni.Pointer<_$jni.Void>,
          _$jni.JMethodIDPtr,
        )>();

/// from: `static public final int getTopLevelField()`
int getTopLevelField() {
  return _getTopLevelField(_TopLevelKtClass.reference.pointer,
          _id_getTopLevelField as _$jni.JMethodIDPtr)
      .integer;
}

final _id_setTopLevelField = _TopLevelKtClass.staticMethodId(
  r'setTopLevelField',
  r'(I)V',
);

final _setTopLevelField = _$jni.ProtectedJniExtensions.lookup<
            _$jni.NativeFunction<
                _$jni.JThrowablePtr Function(_$jni.Pointer<_$jni.Void>,
                    _$jni.JMethodIDPtr, _$jni.VarArgs<(_$jni.Int32,)>)>>(
        'globalEnv_CallStaticVoidMethod')
    .asFunction<
        _$jni.JThrowablePtr Function(
            _$jni.Pointer<_$jni.Void>, _$jni.JMethodIDPtr, int)>();

/// from: `static public final void setTopLevelField(int i)`
void setTopLevelField(
  int i,
) {
  _setTopLevelField(_TopLevelKtClass.reference.pointer,
          _id_setTopLevelField as _$jni.JMethodIDPtr, i)
      .check();
}

final _id_topLevel = _TopLevelKtClass.staticMethodId(
  r'topLevel',
  r'()I',
);

final _topLevel = _$jni.ProtectedJniExtensions.lookup<
        _$jni.NativeFunction<
            _$jni.JniResult Function(
              _$jni.Pointer<_$jni.Void>,
              _$jni.JMethodIDPtr,
            )>>('globalEnv_CallStaticIntMethod')
    .asFunction<
        _$jni.JniResult Function(
          _$jni.Pointer<_$jni.Void>,
          _$jni.JMethodIDPtr,
        )>();

/// from: `static public final int topLevel()`
int topLevel() {
  return _topLevel(_TopLevelKtClass.reference.pointer,
          _id_topLevel as _$jni.JMethodIDPtr)
      .integer;
}

final _id_topLevelSum = _TopLevelKtClass.staticMethodId(
  r'topLevelSum',
  r'(II)I',
);

final _topLevelSum = _$jni.ProtectedJniExtensions.lookup<
            _$jni.NativeFunction<
                _$jni.JniResult Function(
                    _$jni.Pointer<_$jni.Void>,
                    _$jni.JMethodIDPtr,
                    _$jni.VarArgs<(_$jni.Int32, _$jni.Int32)>)>>(
        'globalEnv_CallStaticIntMethod')
    .asFunction<
        _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>, _$jni.JMethodIDPtr, int, int)>();

/// from: `static public final int topLevelSum(int i, int i1)`
int topLevelSum(
  int i,
  int i1,
) {
  return _topLevelSum(_TopLevelKtClass.reference.pointer,
          _id_topLevelSum as _$jni.JMethodIDPtr, i, i1)
      .integer;
}

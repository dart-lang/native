// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../jreference.dart';
import '../types.dart';

final class JBooleanNullableType extends JObjType<JBoolean?> {
  @internal
  const JBooleanNullableType();

  @internal
  @override
  String get signature => r'Ljava/lang/Boolean;';

  @internal
  @override
  JBoolean? fromReference(JReference reference) =>
      reference.isNull ? null : JBoolean.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType<JBoolean?> get nullableType => this;

  @internal
  @override
  final superCount = 2;

  @override
  int get hashCode => (JBooleanNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JBooleanNullableType &&
        other is JBooleanNullableType;
  }
}

final class JBooleanType extends JObjType<JBoolean> {
  @internal
  const JBooleanType();

  @internal
  @override
  String get signature => r'Ljava/lang/Boolean;';

  @internal
  @override
  JBoolean fromReference(JReference reference) =>
      JBoolean.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JBoolean?> get nullableType => const JBooleanNullableType();

  @internal
  @override
  final superCount = 2;

  @override
  int get hashCode => (JBooleanType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JBooleanType && other is JBooleanType;
  }
}

class JBoolean extends JObject {
  @internal
  @override
  // ignore: overridden_fields
  final JObjType<JBoolean> $type = type;

  JBoolean.fromReference(
    super.reference,
  ) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const type = JBooleanType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JBooleanNullableType();

  static final _class = JClass.forName(r'java/lang/Boolean');

  static final _ctorId = _class.constructorId(r'(Z)V');
  JBoolean(bool boolean)
      : super.fromReference(_ctorId(_class, referenceType, [boolean ? 1 : 0]));

  static final _booleanValueId =
      _class.instanceMethodId(r'booleanValue', r'()Z');

  bool booleanValue({bool releaseOriginal = false}) {
    final ret = _booleanValueId(this, const jbooleanType(), []);
    if (releaseOriginal) {
      release();
    }
    return ret;
  }
}

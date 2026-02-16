// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../jreference.dart';
import '../types.dart';

@internal
final class $JBoolean$NullableType$ extends JType<JBoolean?> {
  const $JBoolean$NullableType$();

  @override
  String get signature => r'Ljava/lang/Boolean;';

  @override
  JBoolean? fromReference(JReference reference) =>
      reference.isNull ? null : JBoolean.fromReference(reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JBoolean?> get nullableType => this;

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JBoolean$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JBoolean$NullableType$ &&
        other is $JBoolean$NullableType$;
  }
}

@internal
final class $JBoolean$Type$ extends JType<JBoolean> {
  const $JBoolean$Type$();

  @override
  String get signature => r'Ljava/lang/Boolean;';

  @override
  JBoolean fromReference(JReference reference) =>
      JBoolean.fromReference(reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JBoolean?> get nullableType => const $JBoolean$NullableType$();

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JBoolean$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JBoolean$Type$ && other is $JBoolean$Type$;
  }
}

class JBoolean extends JObject {
  @internal
  @override
  // ignore: overridden_fields
  final JType<JBoolean> $type = type;

  JBoolean.fromReference(super.reference) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const JType<JBoolean> type = $JBoolean$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JBoolean?> nullableType = $JBoolean$NullableType$();

  static final _class = JClass.forName(r'java/lang/Boolean');

  static final _ctorId = _class.constructorId(r'(Z)V');
  JBoolean(bool boolean)
    : super.fromReference(_ctorId(_class, referenceType, [boolean ? 1 : 0]));

  static final _booleanValueId = _class.instanceMethodId(
    r'booleanValue',
    r'()Z',
  );

  bool booleanValue({bool releaseOriginal = false}) {
    final ret = _booleanValueId(this, const jbooleanType(), []);
    if (releaseOriginal) {
      release();
    }
    return ret;
  }
}

// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jreference.dart';
import '../types.dart';
import 'jnumber.dart';

final class JLongNullableType extends JObjType<JLong?> {
  @internal
  const JLongNullableType();

  @internal
  @override
  String get signature => r'Ljava/lang/Long;';

  @internal
  @override
  JLong? fromReference(JReference reference) =>
      reference.isNull ? null : JLong.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JNumberNullableType();

  @internal
  @override
  JObjType<JLong?> get nullableType => this;

  @internal
  @override
  final superCount = 2;

  @override
  int get hashCode => (JLongNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JLongNullableType && other is JLongNullableType;
  }
}

final class JLongType extends JObjType<JLong> {
  @internal
  const JLongType();

  @internal
  @override
  String get signature => r'Ljava/lang/Long;';

  @internal
  @override
  JLong fromReference(JReference reference) => JLong.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JNumberType();

  @internal
  @override
  JObjType<JLong?> get nullableType => const JLongNullableType();

  @internal
  @override
  final superCount = 2;

  @override
  int get hashCode => (JLongType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JLongType && other is JLongType;
  }
}

class JLong extends JNumber {
  @internal
  @override
  // ignore: overridden_fields
  final JObjType<JLong> $type = type;

  JLong.fromReference(
    super.reference,
  ) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const type = JLongType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JLongNullableType();

  static final _class = JClass.forName(r'java/lang/Long');

  static final _ctorId = _class.constructorId(r'(J)V');

  JLong(int num) : super.fromReference(_ctorId(_class, referenceType, [num]));
}

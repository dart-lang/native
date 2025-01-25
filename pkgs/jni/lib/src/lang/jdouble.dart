// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jreference.dart';
import '../types.dart';
import 'jnumber.dart';

final class JDoubleNullableType extends JObjType<JDouble?> {
  @internal
  const JDoubleNullableType();

  @internal
  @override
  String get signature => r'Ljava/lang/Double;';

  @internal
  @override
  JDouble? fromReference(JReference reference) =>
      reference.isNull ? null : JDouble.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JNumberNullableType();

  @internal
  @override
  JObjType<JDouble?> get nullableType => this;

  @internal
  @override
  final superCount = 2;

  @override
  int get hashCode => (JDoubleNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JDoubleNullableType &&
        other is JDoubleNullableType;
  }
}

final class JDoubleType extends JObjType<JDouble> {
  @internal
  const JDoubleType();

  @internal
  @override
  String get signature => r'Ljava/lang/Double;';

  @internal
  @override
  JDouble fromReference(JReference reference) =>
      JDouble.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JNumberType();

  @internal
  @override
  JObjType<JDouble?> get nullableType => const JDoubleNullableType();

  @internal
  @override
  final superCount = 2;

  @override
  int get hashCode => (JDoubleType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JDoubleType && other is JDoubleType;
  }
}

class JDouble extends JNumber {
  @internal
  @override
  // ignore: overridden_fields
  final JObjType<JDouble> $type = type;

  JDouble.fromReference(
    super.reference,
  ) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const type = JDoubleType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JDoubleNullableType();

  static final _class = JClass.forName(r'java/lang/Double');

  static final _ctorId = _class.constructorId(r'(D)V');
  JDouble(double num)
      : super.fromReference(_ctorId(_class, referenceType, [num]));
}

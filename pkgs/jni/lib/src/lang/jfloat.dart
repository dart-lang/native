// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jnumber.dart';

@internal
final class $JFloat$NullableType$ extends JType<JFloat?> {
  const $JFloat$NullableType$();

  @override
  String get signature => r'Ljava/lang/Float;';

  @override
  JFloat? fromReference(JReference reference) =>
      reference.isNull ? null : JFloat.fromReference(reference);

  @override
  JType get superType => const $JNumber$NullableType$();

  @override
  JType<JFloat?> get nullableType => this;

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JFloat$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JFloat$NullableType$ &&
        other is $JFloat$NullableType$;
  }
}

@internal
final class $JFloat$Type$ extends JType<JFloat> {
  const $JFloat$Type$();

  @override
  String get signature => r'Ljava/lang/Float;';

  @override
  JFloat fromReference(JReference reference) => JFloat.fromReference(reference);

  @override
  JType get superType => const $JNumber$Type$();

  @override
  JType<JFloat?> get nullableType => const $JFloat$NullableType$();

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JFloat$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JFloat$Type$ && other is $JFloat$Type$;
  }
}

class JFloat extends JNumber {
  @internal
  @override
  // ignore: overridden_fields
  final JType<JFloat> $type = type;

  JFloat.fromReference(super.reference) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const JType<JFloat> type = $JFloat$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JFloat?> nullableType = $JFloat$NullableType$();

  static final _class = JClass.forName(r'java/lang/Float');

  static final _ctorId = _class.constructorId(r'(F)V');

  JFloat(double num)
    : super.fromReference(_ctorId(_class, referenceType, [JValueFloat(num)]));
}

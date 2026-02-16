// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jnumber.dart';

@internal
final class $JInteger$NullableType$ extends JType<JInteger?> {
  const $JInteger$NullableType$();

  @override
  String get signature => r'Ljava/lang/Integer;';

  @override
  JInteger? fromReference(JReference reference) =>
      reference.isNull ? null : JInteger.fromReference(reference);

  @override
  JType get superType => const $JNumber$NullableType$();

  @override
  JType<JInteger?> get nullableType => this;

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JInteger$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JInteger$NullableType$ &&
        other is $JInteger$NullableType$;
  }
}

@internal
final class $JInteger$Type$ extends JType<JInteger> {
  const $JInteger$Type$();

  @override
  String get signature => r'Ljava/lang/Integer;';

  @override
  JInteger fromReference(JReference reference) =>
      JInteger.fromReference(reference);

  @override
  JType get superType => const $JNumber$Type$();

  @override
  JType<JInteger?> get nullableType => const $JInteger$NullableType$();

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JInteger$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JInteger$Type$ && other is $JInteger$Type$;
  }
}

class JInteger extends JNumber {
  @override
  // ignore: overridden_fields
  final JType<JInteger> $type = type;

  JInteger.fromReference(super.reference) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const JType<JInteger> type = $JInteger$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JInteger?> nullableType = $JInteger$NullableType$();

  static final _class = JClass.forName(r'java/lang/Integer');

  static final _ctorId = _class.constructorId('(I)V');

  JInteger(int num)
    : super.fromReference(_ctorId(_class, referenceType, [JValueInt(num)]));
}

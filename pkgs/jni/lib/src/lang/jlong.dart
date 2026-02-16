// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jreference.dart';
import '../types.dart';
import 'jnumber.dart';

@internal
final class $JLong$NullableType$ extends JType<JLong?> {
  const $JLong$NullableType$();

  @override
  String get signature => r'Ljava/lang/Long;';

  @override
  JLong? fromReference(JReference reference) =>
      reference.isNull ? null : JLong.fromReference(reference);

  @override
  JType get superType => const $JNumber$NullableType$();

  @override
  JType<JLong?> get nullableType => this;

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JLong$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JLong$NullableType$ &&
        other is $JLong$NullableType$;
  }
}

@internal
final class $JLong$Type$ extends JType<JLong> {
  const $JLong$Type$();

  @override
  String get signature => r'Ljava/lang/Long;';

  @override
  JLong fromReference(JReference reference) => JLong.fromReference(reference);

  @override
  JType get superType => const $JNumber$Type$();

  @override
  JType<JLong?> get nullableType => const $JLong$NullableType$();

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JLong$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JLong$Type$ && other is $JLong$Type$;
  }
}

class JLong extends JNumber {
  @internal
  @override
  // ignore: overridden_fields
  final JType<JLong> $type = type;

  JLong.fromReference(super.reference) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const JType<JLong> type = $JLong$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JLong?> nullableType = $JLong$NullableType$();

  static final _class = JClass.forName(r'java/lang/Long');

  static final _ctorId = _class.constructorId(r'(J)V');

  JLong(int num) : super.fromReference(_ctorId(_class, referenceType, [num]));
}

// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jnumber.dart';

@internal
final class $JByte$NullableType$ extends JType<JByte?> {
  const $JByte$NullableType$();

  @override
  String get signature => r'Ljava/lang/Byte;';

  @override
  JByte? fromReference(JReference reference) =>
      reference.isNull ? null : JByte.fromReference(reference);

  @override
  JType get superType => const $JNumber$NullableType$();

  @override
  JType<JByte?> get nullableType => this;

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JByte$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JByte$NullableType$ &&
        other is $JByte$NullableType$;
  }
}

@internal
final class $JByte$Type$ extends JType<JByte> {
  const $JByte$Type$();

  @override
  String get signature => r'Ljava/lang/Byte;';

  @override
  JByte fromReference(JReference reference) => JByte.fromReference(reference);

  @override
  JType get superType => const $JNumber$Type$();

  @override
  JType<JByte?> get nullableType => const $JByte$NullableType$();

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JByte$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JByte$Type$ && other is $JByte$Type$;
  }
}

class JByte extends JNumber {
  @internal
  @override
  // ignore: overridden_fields
  final JType<JByte> $type = type;

  JByte.fromReference(
    super.reference,
  ) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const JType<JByte> type = $JByte$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JByte?> nullableType = $JByte$NullableType$();

  static final _class = JClass.forName(r'java/lang/Byte');

  static final _ctorId = _class.constructorId(r'(B)V');
  JByte(int num)
      : super.fromReference(_ctorId(_class, referenceType, [JValueByte(num)]));
}

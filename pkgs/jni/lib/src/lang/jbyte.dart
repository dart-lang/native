// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jnumber.dart';

final class JByteNullableType extends JObjType<JByte?> {
  @internal
  const JByteNullableType();

  @internal
  @override
  String get signature => r'Ljava/lang/Byte;';

  @internal
  @override
  JByte? fromReference(JReference reference) =>
      reference.isNull ? null : JByte.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JNumberNullableType();

  @internal
  @override
  JObjType<JByte?> get nullableType => this;

  @internal
  @override
  final superCount = 2;

  @override
  int get hashCode => (JByteNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JByteNullableType && other is JByteNullableType;
  }
}

final class JByteType extends JObjType<JByte> {
  @internal
  const JByteType();

  @internal
  @override
  String get signature => r'Ljava/lang/Byte;';

  @internal
  @override
  JByte fromReference(JReference reference) => JByte.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JNumberType();

  @internal
  @override
  JObjType<JByte?> get nullableType => const JByteNullableType();

  @internal
  @override
  final superCount = 2;

  @override
  int get hashCode => (JByteType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JByteType && other is JByteType;
  }
}

class JByte extends JNumber {
  @internal
  @override
  // ignore: overridden_fields
  final JObjType<JByte> $type = type;

  JByte.fromReference(
    super.reference,
  ) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const type = JByteType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JByteNullableType();

  static final _class = JClass.forName(r'java/lang/Byte');

  static final _ctorId = _class.constructorId(r'(B)V');
  JByte(int num)
      : super.fromReference(_ctorId(_class, referenceType, [JValueByte(num)]));
}

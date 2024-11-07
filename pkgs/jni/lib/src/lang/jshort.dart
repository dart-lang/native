// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jnumber.dart';

final class JShortNullableType extends JObjType<JShort?> {
  @internal
  const JShortNullableType();

  @internal
  @override
  String get signature => r'Ljava/lang/Short;';

  @internal
  @override
  JShort? fromReference(JReference reference) =>
      reference.isNull ? null : JShort.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JNumberNullableType();

  @internal
  @override
  JObjType<JShort?> get nullableType => this;

  @internal
  @override
  final superCount = 2;

  @override
  int get hashCode => (JShortNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JShortNullableType &&
        other is JShortNullableType;
  }
}

final class JShortType extends JObjType<JShort> {
  @internal
  const JShortType();

  @internal
  @override
  String get signature => r'Ljava/lang/Short;';

  @internal
  @override
  JShort fromReference(JReference reference) => JShort.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JNumberType();

  @internal
  @override
  JObjType<JShort?> get nullableType => const JShortNullableType();

  @internal
  @override
  final superCount = 2;

  @override
  int get hashCode => (JShortType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JShortType && other is JShortType;
  }
}

class JShort extends JNumber {
  @internal
  @override
  // ignore: overridden_fields
  final JObjType<JShort> $type = type;

  JShort.fromReference(
    super.reference,
  ) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const type = JShortType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JShortNullableType();

  static final _class = JClass.forName(r'java/lang/Short');

  static final _ctorId = _class.constructorId(r'(S)V');

  JShort(int num)
      : super.fromReference(_ctorId(_class, referenceType, [JValueShort(num)]));
}

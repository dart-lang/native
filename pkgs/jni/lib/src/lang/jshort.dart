// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jnumber.dart';

@internal
final class $JShort$NullableType$ extends JType<JShort?> {
  const $JShort$NullableType$();

  @override
  String get signature => r'Ljava/lang/Short;';

  @override
  JShort? fromReference(JReference reference) =>
      reference.isNull ? null : JShort.fromReference(reference);

  @override
  JType get superType => const $JNumber$NullableType$();

  @override
  JType<JShort?> get nullableType => this;

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JShort$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JShort$NullableType$ &&
        other is $JShort$NullableType$;
  }
}

@internal
final class $JShort$Type$ extends JType<JShort> {
  const $JShort$Type$();

  @override
  String get signature => r'Ljava/lang/Short;';

  @override
  JShort fromReference(JReference reference) => JShort.fromReference(reference);

  @override
  JType get superType => const $JNumber$Type$();

  @override
  JType<JShort?> get nullableType => const $JShort$NullableType$();

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JShort$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JShort$Type$ && other is $JShort$Type$;
  }
}

class JShort extends JNumber {
  @internal
  @override
  // ignore: overridden_fields
  final JType<JShort> $type = type;

  JShort.fromReference(
    super.reference,
  ) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const JType<JShort> type = $JShort$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JShort?> nullableType = $JShort$NullableType$();

  static final _class = JClass.forName(r'java/lang/Short');

  static final _ctorId = _class.constructorId(r'(S)V');

  JShort(int num)
      : super.fromReference(_ctorId(_class, referenceType, [JValueShort(num)]));
}

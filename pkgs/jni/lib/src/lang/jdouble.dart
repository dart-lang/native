// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jreference.dart';
import '../types.dart';
import 'jnumber.dart';

@internal
final class $JDouble$NullableType$ extends JType<JDouble?> {
  const $JDouble$NullableType$();

  @override
  String get signature => r'Ljava/lang/Double;';

  @override
  JDouble? fromReference(JReference reference) =>
      reference.isNull ? null : JDouble.fromReference(reference);

  @override
  JType get superType => const $JNumber$NullableType$();

  @override
  JType<JDouble?> get nullableType => this;

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JDouble$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JDouble$NullableType$ &&
        other is $JDouble$NullableType$;
  }
}

@internal
final class $JDouble$Type$ extends JType<JDouble> {
  const $JDouble$Type$();

  @override
  String get signature => r'Ljava/lang/Double;';

  @override
  JDouble fromReference(JReference reference) =>
      JDouble.fromReference(reference);

  @override
  JType get superType => const $JNumber$Type$();

  @override
  JType<JDouble?> get nullableType => const $JDouble$NullableType$();

  @override
  final superCount = 2;

  @override
  int get hashCode => ($JDouble$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JDouble$Type$ && other is $JDouble$Type$;
  }
}

class JDouble extends JNumber {
  @internal
  @override
  // ignore: overridden_fields
  final JType<JDouble> $type = type;

  JDouble.fromReference(super.reference) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const JType<JDouble> type = $JDouble$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JDouble?> nullableType = $JDouble$NullableType$();

  static final _class = JClass.forName(r'java/lang/Double');

  static final _ctorId = _class.constructorId(r'(D)V');
  JDouble(double num)
    : super.fromReference(_ctorId(_class, referenceType, [num]));
}

// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jnumber.dart';

final class JFloatType extends JObjType<JFloat> {
  const JFloatType();

  @override
  String get signature => r"Ljava/lang/Float;";

  @override
  JFloat fromReference(JReference reference) => JFloat.fromReference(reference);

  @override
  JObjType get superType => const JNumberType();

  @override
  final superCount = 2;

  @override
  int get hashCode => (JFloatType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JFloatType && other is JFloatType;
  }
}

class JFloat extends JNumber {
  @override
  // ignore: overridden_fields
  late final JObjType<JFloat> $type = type;

  JFloat.fromReference(
    JReference reference,
  ) : super.fromReference(reference);

  /// The type which includes information such as the signature of this class.
  static const type = JFloatType();

  static final _class = JClass.forName(r"java/lang/Float");

  static final _ctorId = _class.constructorId(r"(F)V");

  JFloat(double num)
      : super.fromReference(_ctorId(_class, referenceType, [JValueFloat(num)]));
}

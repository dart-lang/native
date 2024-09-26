// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jnumber.dart';

final class JIntegerType extends JObjType<JInteger> {
  @internal
  const JIntegerType();

  @internal
  @override
  String get signature => r'Ljava/lang/Integer;';

  @internal
  @override
  JInteger fromReference(JReference reference) =>
      JInteger.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JNumberType();

  @internal
  @override
  final superCount = 2;

  @override
  int get hashCode => (JIntegerType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JIntegerType && other is JIntegerType;
  }
}

class JInteger extends JNumber {
  @internal
  @override
  // ignore: overridden_fields
  final JObjType<JInteger> $type = type;

  JInteger.fromReference(
    super.reference,
  ) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const type = JIntegerType();

  static final _class = JClass.forName(r'java/lang/Integer');

  static final _ctorId = _class.constructorId('(I)V');

  JInteger(int num)
      : super.fromReference(_ctorId(_class, referenceType, [JValueInt(num)]));
}

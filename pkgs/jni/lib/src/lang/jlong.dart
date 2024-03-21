// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../jreference.dart';
import '../types.dart';
import 'jnumber.dart';

final class JLongType extends JObjType<JLong> {
  const JLongType();

  @override
  String get signature => r"Ljava/lang/Long;";

  @override
  JLong fromReference(JReference reference) => JLong.fromReference(reference);

  @override
  JObjType get superType => const JNumberType();

  @override
  final superCount = 2;

  @override
  int get hashCode => (JLongType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JLongType && other is JLongType;
  }
}

class JLong extends JNumber {
  @override
  // ignore: overridden_fields
  late final JObjType<JLong> $type = type;

  JLong.fromReference(
    JReference reference,
  ) : super.fromReference(reference);

  /// The type which includes information such as the signature of this class.
  static const type = JLongType();

  static final _class = JClass.forName(r"java/lang/Long");

  static final _ctorId = _class.constructorId(r"(J)V");

  JLong(int num) : super.fromReference(_ctorId(_class, referenceType, [num]));
}

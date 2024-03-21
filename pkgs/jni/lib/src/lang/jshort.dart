// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jnumber.dart';

final class JShortType extends JObjType<JShort> {
  const JShortType();

  @override
  String get signature => r"Ljava/lang/Short;";

  @override
  JShort fromReference(JReference reference) => JShort.fromReference(reference);

  @override
  JObjType get superType => const JNumberType();

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
  @override
  // ignore: overridden_fields
  late final JObjType<JShort> $type = type;

  JShort.fromReference(
    JReference reference,
  ) : super.fromReference(reference);

  /// The type which includes information such as the signature of this class.
  static const type = JShortType();

  static final _class = JClass.forName(r"java/lang/Short");

  static final _ctorId = _class.constructorId(r"(S)V");

  JShort(int num)
      : super.fromReference(_ctorId(_class, referenceType, [JValueShort(num)]));
}

// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../accessors.dart';
import '../jni.dart';
import '../jvalues.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';
import 'jnumber.dart';

final class JFloatType extends JObjType<JFloat> {
  const JFloatType();

  @override
  String get signature => r"Ljava/lang/Float;";

  @override
  JFloat fromReference(JObjectPtr ref) => JFloat.fromReference(ref);

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
    JObjectPtr ref,
  ) : super.fromReference(ref);

  /// The type which includes information such as the signature of this class.
  static const type = JFloatType();

  static final _class = Jni.findJClass(r"java/lang/Float");

  static final _ctorId =
      Jni.accessors.getMethodIDOf(_class.reference.pointer, r"<init>", r"(F)V");

  JFloat(double num)
      : super.fromReference(Jni.accessors.newObjectWithArgs(
            _class.reference.pointer, _ctorId, [JValueFloat(num)]).object);
}

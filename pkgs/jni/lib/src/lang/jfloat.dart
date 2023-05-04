// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../accessors.dart';
import '../jni.dart';
import '../jvalues.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';
import 'jnumber.dart';

class JFloatType extends JObjType<JFloat> {
  const JFloatType();

  @override
  String get signature => r"Ljava/lang/Float;";

  @override
  JFloat fromRef(JObjectPtr ref) => JFloat.fromRef(ref);

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

  JFloat.fromRef(
    JObjectPtr ref,
  ) : super.fromRef(ref);

  /// The type which includes information such as the signature of this class.
  static const type = JFloatType();

  static final _class = Jni.findJClass(r"java/lang/Float");

  static final _ctorId =
      Jni.accessors.getMethodIDOf(_class.reference, r"<init>", r"(F)V");

  JFloat(double num)
      : super.fromRef(Jni.accessors.newObjectWithArgs(
            _class.reference, _ctorId, [JValueFloat(num)]).object);
}

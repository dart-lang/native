// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../accessors.dart';
import '../jni.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';
import 'jnumber.dart';

final class JDoubleType extends JObjType<JDouble> {
  const JDoubleType();

  @override
  String get signature => r"Ljava/lang/Double;";

  @override
  JDouble fromRef(JObjectPtr ref) => JDouble.fromRef(ref);

  @override
  JObjType get superType => const JNumberType();

  @override
  final superCount = 2;

  @override
  int get hashCode => (JDoubleType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JDoubleType && other is JDoubleType;
  }
}

class JDouble extends JNumber {
  @override
  // ignore: overridden_fields
  late final JObjType<JDouble> $type = type;

  JDouble.fromRef(
    JObjectPtr ref,
  ) : super.fromRef(ref);

  /// The type which includes information such as the signature of this class.
  static const type = JDoubleType();

  static final _class = Jni.findJClass(r"java/lang/Double");

  static final _ctorId =
      Jni.accessors.getMethodIDOf(_class.reference.pointer, r"<init>", r"(D)V");
  JDouble(double num)
      : super.fromRef(Jni.accessors.newObjectWithArgs(
            _class.reference.pointer, _ctorId, [num]).object);
}

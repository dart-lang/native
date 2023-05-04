// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../accessors.dart';
import '../jni.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';
import 'jnumber.dart';

class JLongType extends JObjType<JLong> {
  const JLongType();

  @override
  String get signature => r"Ljava/lang/Long;";

  @override
  JLong fromRef(JObjectPtr ref) => JLong.fromRef(ref);

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

  JLong.fromRef(
    JObjectPtr ref,
  ) : super.fromRef(ref);

  /// The type which includes information such as the signature of this class.
  static const type = JLongType();

  static final _class = Jni.findJClass(r"java/lang/Long");

  static final _ctorId =
      Jni.accessors.getMethodIDOf(_class.reference, r"<init>", r"(J)V");

  JLong(int num)
      : super.fromRef(Jni.accessors
            .newObjectWithArgs(_class.reference, _ctorId, [num]).object);
}

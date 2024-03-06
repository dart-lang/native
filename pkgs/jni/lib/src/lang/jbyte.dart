// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../accessors.dart';
import '../jni.dart';
import '../jvalues.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';
import 'jnumber.dart';

final class JByteType extends JObjType<JByte> {
  const JByteType();

  @override
  String get signature => r"Ljava/lang/Byte;";

  @override
  JByte fromRef(JObjectPtr ref) => JByte.fromRef(ref);

  @override
  JObjType get superType => const JNumberType();

  @override
  final superCount = 2;

  @override
  int get hashCode => (JByteType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JByteType && other is JByteType;
  }
}

class JByte extends JNumber {
  @override
  // ignore: overridden_fields
  late final JObjType<JByte> $type = type;

  JByte.fromRef(
    JObjectPtr ref,
  ) : super.fromRef(ref);

  /// The type which includes information such as the signature of this class.
  static const type = JByteType();

  static final _class = Jni.findJClass(r"java/lang/Byte");

  static final _ctorId =
      Jni.accessors.getMethodIDOf(_class.reference.pointer, r"<init>", r"(B)V");
  JByte(int num)
      : super.fromRef(Jni.accessors.newObjectWithArgs(
            _class.reference.pointer, _ctorId, [JValueByte(num)]).object);
}

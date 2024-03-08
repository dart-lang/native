// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../accessors.dart';
import '../jni.dart';
import '../jvalues.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';
import 'jnumber.dart';

final class JIntegerType extends JObjType<JInteger> {
  const JIntegerType();

  @override
  String get signature => r"Ljava/lang/Integer;";

  @override
  JInteger fromReference(JObjectPtr ref) => JInteger.fromReference(ref);

  @override
  JObjType get superType => const JNumberType();

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
  @override
  // ignore: overridden_fields
  late final JObjType<JInteger> $type = type;

  JInteger.fromReference(
    JObjectPtr ref,
  ) : super.fromReference(ref);

  /// The type which includes information such as the signature of this class.
  static const type = JIntegerType();

  static final _class = Jni.findJClass(r"java/lang/Integer");

  static final _ctorId =
      Jni.accessors.getMethodIDOf(_class.reference.pointer, r"<init>", r"(I)V");

  JInteger(int num)
      : super.fromReference(Jni.accessors.newObjectWithArgs(
            _class.reference.pointer, _ctorId, [JValueInt(num)]).object);
}

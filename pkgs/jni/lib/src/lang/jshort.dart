// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../accessors.dart';
import '../jni.dart';
import '../jvalues.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';
import 'jnumber.dart';

final class JShortType extends JObjType<JShort> {
  const JShortType();

  @override
  String get signature => r"Ljava/lang/Short;";

  @override
  JShort fromRef(JObjectPtr ref) => JShort.fromRef(ref);

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

  JShort.fromRef(
    JObjectPtr ref,
  ) : super.fromRef(ref);

  /// The type which includes information such as the signature of this class.
  static const type = JShortType();

  static final _class = Jni.findJClass(r"java/lang/Short");

  static final _ctorId =
      Jni.accessors.getMethodIDOf(_class.reference.pointer, r"<init>", r"(S)V");

  JShort(int num)
      : super.fromRef(Jni.accessors.newObjectWithArgs(
            _class.reference.pointer, _ctorId, [JValueShort(num)]).object);
}

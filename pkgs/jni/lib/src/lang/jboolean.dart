// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../accessors.dart';
import '../jobject.dart';
import '../jreference.dart';
import '../jni.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';

class JBooleanType extends JObjType<JBoolean> {
  const JBooleanType();

  @override
  String get signature => r"Ljava/lang/Boolean;";

  @override
  JBoolean fromRef(JObjectPtr ref) => JBoolean.fromRef(ref);

  @override
  JObjType get superType => const JObjectType();

  @override
  final superCount = 2;

  @override
  int get hashCode => (JBooleanType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JBooleanType && other is JBooleanType;
  }
}

class JBoolean extends JObject {
  @override
  // ignore: overridden_fields
  late final JObjType<JBoolean> $type = type;

  JBoolean.fromRef(
    JObjectPtr ref,
  ) : super.fromRef(ref);

  /// The type which includes information such as the signature of this class.
  static const type = JBooleanType();

  static final _class = Jni.findJClass(r"java/lang/Boolean");

  static final _ctorId =
      Jni.accessors.getMethodIDOf(_class.reference, r"<init>", r"(Z)V");
  JBoolean(bool boolean)
      : super.fromRef(Jni.accessors.newObjectWithArgs(
            _class.reference, _ctorId, [boolean ? 1 : 0]).object);

  static final _booleanValueId =
      Jni.accessors.getMethodIDOf(_class.reference, r"booleanValue", r"()Z");

  bool booleanValue({bool deleteOriginal = false}) {
    ensureNotNull();
    final ret = Jni.accessors.callMethodWithArgs(
        reference, _booleanValueId, JniCallType.booleanType, []).boolean;
    if (deleteOriginal) {
      delete();
    }
    return ret;
  }
}

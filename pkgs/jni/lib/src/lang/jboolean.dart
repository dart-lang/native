// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../jobject.dart';
import '../jreference.dart';
import '../types.dart';

final class JBooleanType extends JObjType<JBoolean> {
  const JBooleanType();

  @override
  String get signature => r"Ljava/lang/Boolean;";

  @override
  JBoolean fromReference(JReference reference) =>
      JBoolean.fromReference(reference);

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

  JBoolean.fromReference(
    JReference reference,
  ) : super.fromReference(reference);

  /// The type which includes information such as the signature of this class.
  static const type = JBooleanType();

  static final _class = JClass.forName(r"java/lang/Boolean");

  static final _ctorId = _class.constructorId(r"(Z)V");
  JBoolean(bool boolean)
      : super.fromReference(_ctorId(_class, referenceType, [boolean ? 1 : 0]));

  static final _booleanValueId =
      _class.instanceMethodId(r"booleanValue", r"()Z");

  bool booleanValue({bool releaseOriginal = false}) {
    reference.ensureNotNull();
    final ret = _booleanValueId(this, const jbooleanType(), []);
    if (releaseOriginal) {
      release();
    }
    return ret;
  }
}

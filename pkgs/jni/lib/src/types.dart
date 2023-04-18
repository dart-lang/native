// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';

import 'accessors.dart';
import 'jni.dart';
import 'jvalues.dart';
import 'third_party/generated_bindings.dart';

part 'jarray.dart';
part 'jexceptions.dart';
part 'jprimitives.dart';
part 'jreference.dart';
part 'jobject.dart';
part 'jstring.dart';

final Pointer<JniAccessors> _accessors = Jni.accessors;
final Pointer<GlobalJniEnv> _env = Jni.env;
// This typedef is needed because void is a keyword and cannot be used in
// type switch like a regular type.
typedef _VoidType = void;

abstract class JType<T> {
  const JType();

  int get _type;

  String get signature;
}

abstract class JObjType<T extends JObject> extends JType<T> {
  /// Number of super types. Distance to the root type.
  int get superCount;

  JObjType get superType;

  const JObjType();

  @override
  int get _type => JniCallType.objectType;

  /// Creates an object from this type using the reference.
  T fromRef(Pointer<Void> ref);

  JClass getClass() {
    if (signature.startsWith('L') && signature.endsWith(';')) {
      return Jni.findJClass(signature.substring(1, signature.length - 1));
    }
    return Jni.findJClass(signature);
  }
}

/// Lowest common ancestor of two types in the inheritance tree.
JObjType _lowestCommonAncestor(JObjType a, JObjType b) {
  while (a.superCount > b.superCount) {
    a = a.superType;
  }
  while (b.superCount > a.superCount) {
    b = b.superType;
  }
  while (a != b) {
    a = a.superType;
    b = b.superType;
  }
  return a;
}

JObjType lowestCommonSuperType(List<JObjType> types) {
  return types.reduce(_lowestCommonAncestor);
}

// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'jni.dart';
import 'jobject.dart';

part 'jprimitives.dart';

sealed class JType<T> {
  const JType();

  String get signature;
}

abstract class JObjType<T extends JObject> extends JType<T> {
  /// Number of super types. Distance to the root type.
  int get superCount;

  JObjType get superType;

  const JObjType();

  /// Creates an object from this type using the reference.
  T fromReference(Pointer<Void> ref);

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

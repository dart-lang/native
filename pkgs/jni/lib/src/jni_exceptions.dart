// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'third_party/jni_bindings_generated.dart';

class UseAfterFreeException implements Exception {
  dynamic object;
  Pointer<Void> ptr;
  UseAfterFreeException(this.object, this.ptr);

  @override
  String toString() {
    return "use after free on $ptr through $object";
  }
}

class NullJniStringException implements Exception {
  @override
  String toString() => 'toDartString called on null JniString reference';
}

class DoubleFreeException implements Exception {
  dynamic object;
  Pointer<Void> ptr;
  DoubleFreeException(this.object, this.ptr);

  @override
  String toString() {
    return "double free on $ptr through $object";
  }
}

class JvmExistsException implements Exception {
  @override
  String toString() => 'A JVM already exists';
}

class NoJvmInstanceException implements Exception {
  @override
  String toString() => 'No JNI instance is available';
}

extension JniTypeNames on int {
  static const _names = {
    JniType.boolType: 'bool',
    JniType.byteType: 'byte',
    JniType.shortType: 'short',
    JniType.charType: 'char',
    JniType.intType: 'int',
    JniType.longType: 'long',
    JniType.floatType: 'float',
    JniType.doubleType: 'double',
    JniType.objectType: 'object',
    JniType.voidType: 'void',
  };
  String str() => _names[this]!;
}

class InvalidCallTypeException implements Exception {
  int type;
  Set<int> allowed;
  InvalidCallTypeException(this.type, this.allowed);
  @override
  String toString() => 'Invalid type for call ${type.str()}. '
      'Allowed types are ${allowed.map((t) => t.str()).toSet()}';
}

class JniException implements Exception {
  /// Exception object pointer from JNI.
  final JObject err;

  /// brief description, usually initialized with error message from Java.
  final String msg;
  JniException(this.err, this.msg);

  @override
  String toString() => msg;
}

class HelperNotFoundException implements Exception {
  HelperNotFoundException(this.path);
  final String path;

  @override
  String toString() => "Lookup for helper library $path failed.\n"
      "Please ensure that `dartjni` shared library is built.\n"
      "Provided jni:setup script can be used to build the shared library."
      "If the library is already built, double check the path.";
}

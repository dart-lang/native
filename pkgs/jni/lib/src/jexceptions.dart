// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:jni/src/third_party/generated_bindings.dart';

abstract class JException implements Exception {}

class UseAfterFreeException implements JException {
  final Pointer<Void> ptr;
  UseAfterFreeException(this.ptr);

  @override
  String toString() {
    return 'Use after free on $ptr.';
  }
}

class JNullException implements JException {
  const JNullException();

  @override
  String toString() => 'The reference was null.';
}

class InvalidJStringException implements JException {
  final Pointer<Void> reference;
  InvalidJStringException(this.reference);

  @override
  String toString() => 'Not a valid Java String: '
      '0x${reference.address.toRadixString(16)}.';
}

class DoubleFreeException implements JException {
  final Pointer<Void> ptr;
  DoubleFreeException(this.ptr);

  @override
  String toString() {
    return 'Double free on $ptr.';
  }
}

class JvmExistsException implements JException {
  @override
  String toString() => 'A JVM is already spawned';
}

/// Represents spawn errors that might be returned by JNI_CreateJavaVM
class SpawnException implements JException {
  static const _errors = {
    JniErrorCode.JNI_ERR: 'Generic JNI error',
    JniErrorCode.JNI_EDETACHED: 'Thread detached from VM',
    JniErrorCode.JNI_EVERSION: 'JNI version error',
    JniErrorCode.JNI_ENOMEM: 'Out of memory',
    JniErrorCode.JNI_EEXIST: 'VM Already created',
    JniErrorCode.JNI_EINVAL: 'Invalid arguments',
  };
  int status;
  SpawnException.of(this.status);

  @override
  String toString() => _errors[status] ?? 'Unknown status code: $status';
}

class NoJvmInstanceException implements JException {
  @override
  String toString() => 'No JNI instance is available';
}

extension JniTypeNames on int {
  static const _names = {
    JniCallType.booleanType: 'bool',
    JniCallType.byteType: 'byte',
    JniCallType.shortType: 'short',
    JniCallType.charType: 'char',
    JniCallType.intType: 'int',
    JniCallType.longType: 'long',
    JniCallType.floatType: 'float',
    JniCallType.doubleType: 'double',
    JniCallType.objectType: 'object',
    JniCallType.voidType: 'void',
  };
  String str() => _names[this]!;
}

class InvalidCallTypeException implements JException {
  int type;
  Set<int> allowed;
  InvalidCallTypeException(this.type, this.allowed);
  @override
  String toString() => 'Invalid type for call ${type.str()}. '
      'Allowed types are ${allowed.map((t) => t.str()).toSet()}';
}

class JniException implements JException {
  /// Error message from Java exception.
  final String message;

  /// Stack trace from Java.
  final String stackTrace;
  JniException(this.message, this.stackTrace);

  @override
  String toString() => 'Exception in Java code called through JNI: '
      '$message\n\n$stackTrace\n';
}

class HelperNotFoundException implements JException {
  HelperNotFoundException(this.path);
  final String path;

  @override
  String toString() => '''
Lookup for helper library $path failed.
Please ensure that `dartjni` shared library is built.
Provided jni:setup script can be used to build the shared library.
If the library is already built, ensure that the JVM libraries can be 
loaded from Dart.''';
}

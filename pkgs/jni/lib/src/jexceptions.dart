// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'types.dart';

abstract class JException implements Exception {}

class UseAfterFreeException implements JException {
  dynamic object;
  Pointer<Void> ptr;
  UseAfterFreeException(this.object, this.ptr);

  @override
  String toString() {
    return "use after free on $ptr through $object";
  }
}

class NullJStringException implements JException {
  @override
  String toString() => 'toDartString called on null JString reference';
}

class InvalidJStringException implements JException {
  Pointer<Void> reference;
  InvalidJStringException(this.reference);
  @override
  String toString() => 'Not a valid Java String: '
      '0x${reference.address.toRadixString(16)}';
}

class DoubleFreeException implements JException {
  dynamic object;
  Pointer<Void> ptr;
  DoubleFreeException(this.object, this.ptr);

  @override
  String toString() {
    return "double free on $ptr through $object";
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
  String toString() => "Lookup for helper library $path failed.\n"
      "Please ensure that `dartjni` shared library is built.\n"
      "Provided jni:setup script can be used to build the shared library."
      "If the library is already built, ensure that the JVM libraries can be "
      "loaded from Dart.";
}

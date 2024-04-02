// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni/src/third_party/generated_bindings.dart';

// TODO(#567): Add the fact that [JException] is now a [JObject] to the
// CHANGELOG.

final class UseAfterReleaseError extends StateError {
  UseAfterReleaseError() : super('Use after release error');
}

// TODO(#567): Use NullPointerError once it's available.
final class JNullError extends StateError {
  JNullError() : super('The reference was null');
}

final class DoubleReleaseError extends StateError {
  DoubleReleaseError() : super('Double release error');
}

/// Represents JNI errors that might be returned by methods like
/// `JNI_CreateJavaVM`.
sealed class JniError extends Error {
  static const _errors = {
    JniErrorCode.JNI_ERR: JniGenericError.new,
    JniErrorCode.JNI_EDETACHED: JniThreadDetachedError.new,
    JniErrorCode.JNI_EVERSION: JniVersionError.new,
    JniErrorCode.JNI_ENOMEM: JniOutOfMemoryError.new,
    JniErrorCode.JNI_EEXIST: JniVmExistsError.new,
    JniErrorCode.JNI_EINVAL: JniArgumentError.new,
  };

  final String message;

  JniError(this.message);

  factory JniError.of(int status) {
    if (!_errors.containsKey(status)) {
      status = JniErrorCode.JNI_ERR;
    }
    return _errors[status]!();
  }

  @override
  String toString() {
    return 'JniError: $message';
  }
}

final class JniGenericError extends JniError {
  JniGenericError() : super('Generic JNI error');
}

final class JniThreadDetachedError extends JniError {
  JniThreadDetachedError() : super('Thread detached from VM');
}

final class JniVersionError extends JniError {
  JniVersionError() : super('JNI version error');
}

final class JniOutOfMemoryError extends JniError {
  JniOutOfMemoryError() : super('Out of memory');
}

final class JniVmExistsError extends JniError {
  JniVmExistsError() : super('VM Already created');
}

final class JniArgumentError extends JniError {
  JniArgumentError() : super('Invalid arguments');
}

final class NoJvmInstanceError extends Error {
  @override
  String toString() => 'No JNI instance is available';
}

// TODO(#567): Remove this class in favor of `JThrowable`.
class JniException implements Exception {
  /// Error message from Java exception.
  final String message;

  /// Stack trace from Java.
  final String stackTrace;

  JniException(this.message, this.stackTrace);

  @override
  String toString() => 'Exception in Java code called through JNI: '
      '$message\n\n$stackTrace\n';
}

final class HelperNotFoundError extends Error {
  final String path;

  HelperNotFoundError(this.path);

  @override
  String toString() => '''
Lookup for helper library $path failed.
Please ensure that `dartjni` shared library is built.
Provided jni:setup script can be used to build the shared library.
If the library is already built, ensure that the JVM libraries can be 
loaded from Dart.''';
}

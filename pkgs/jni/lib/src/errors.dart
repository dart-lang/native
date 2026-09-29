// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:meta/meta.dart' show internal;

import 'third_party/generated_bindings.dart';

// TODO(#567): Add the fact that [JException] is now a [JObject] to the
// CHANGELOG.

mixin _ExplainsRelease on StateError {
  String? get releaseStackTrace;

  @override
  String toString() {
    final sb = StringBuffer(super.toString());
    if (releaseStackTrace != null) {
      sb.write('\n');
      sb.write(releaseStackTrace);
    } else {
      sb.writeln('\nTo see where the object was released, '
          'set `Jni.captureStackTraceOnRelease = true`.');
    }
    return sb.toString();
  }
}

/// Error thrown when an operation is performed on an object whose underlying
/// JNI reference has been released.
final class UseAfterReleaseError extends StateError with _ExplainsRelease {
  /// The stack trace where the object was released, if captured.
  @override
  final String? releaseStackTrace;

  /// Creates a [UseAfterReleaseError] with an optional [releaseStackTrace].
  UseAfterReleaseError([this.releaseStackTrace])
      : super('Use after release error');
}

// TODO(#567): Use NullPointerError once it's available.
/// Error thrown when an unexpected null reference is encountered.
final class JNullError extends StateError {
  /// Creates a [JNullError].
  JNullError() : super('The reference was null');
}

/// Error thrown when a Java method or field cannot be found.
final class NoSuchMethodError extends StateError {
  /// The name of the missing method or field.
  final String name;

  /// Creates a [NoSuchMethodError] for the method or field with [name].
  NoSuchMethodError(this.name) : super('No such method or field: $name');
}

/// Error thrown when attempting to release an already-released JNI reference.
final class DoubleReleaseError extends StateError with _ExplainsRelease {
  /// The stack trace where the object was first released, if captured.
  @override
  final String? releaseStackTrace;

  /// Creates a [DoubleReleaseError] with an optional [releaseStackTrace].
  DoubleReleaseError([this.releaseStackTrace]) : super('Double release error');
}

/// Represents JNI errors that might be returned by methods like `CreateJavaVM`.
sealed class JniError extends Error {
  static const _errors = {
    JniErrorCode.ERR: JniGenericError.new,
    JniErrorCode.EDETACHED: JniThreadDetachedError.new,
    JniErrorCode.EVERSION: JniVersionError.new,
    JniErrorCode.ENOMEM: JniOutOfMemoryError.new,
    JniErrorCode.EEXIST: JniVmExistsError.new,
    JniErrorCode.EINVAL: JniArgumentError.new,
  };

  /// The error message describing this JNI error.
  final String message;

  /// Creates a [JniError] with the given [message].
  JniError(this.message);

  @internal
  factory JniError.of(JniErrorCode status) {
    if (!_errors.containsKey(status)) {
      status = JniErrorCode.ERR;
    }
    return _errors[status]!();
  }

  @override
  String toString() {
    return 'JniError: $message';
  }
}

/// Error representing a generic JNI failure.
final class JniGenericError extends JniError {
  /// Creates a [JniGenericError].
  JniGenericError() : super('Generic JNI error');
}

/// Error representing a thread detached from the Java VM.
final class JniThreadDetachedError extends JniError {
  /// Creates a [JniThreadDetachedError].
  JniThreadDetachedError() : super('Thread detached from VM');
}

/// Error representing a JNI version error.
final class JniVersionError extends JniError {
  /// Creates a [JniVersionError].
  JniVersionError() : super('JNI version error');
}

/// Error representing a JNI out of memory condition.
final class JniOutOfMemoryError extends JniError {
  /// Creates a [JniOutOfMemoryError].
  JniOutOfMemoryError() : super('Out of memory');
}

/// Error representing that a Java VM has already been created.
final class JniVmExistsError extends JniError {
  /// Creates a [JniVmExistsError].
  JniVmExistsError() : super('VM Already created');
}

/// Error representing invalid arguments passed to a JNI function.
final class JniArgumentError extends JniError {
  /// Creates a [JniArgumentError].
  JniArgumentError() : super('Invalid arguments');
}

/// Error thrown when attempting an operation that requires a JVM instance,
/// but none is running.
final class NoJvmInstanceError extends Error {
  /// Creates a [NoJvmInstanceError].
  NoJvmInstanceError();

  @override
  String toString() => 'No JNI instance is available';
}

/// Error thrown when the JNI helper shared library cannot be found.
final class HelperNotFoundError extends Error {
  /// The path where the helper library was expected to be.
  final String path;

  /// Creates a [HelperNotFoundError] for the given [path].
  HelperNotFoundError(this.path);

  @override
  String toString() => '''
Unable to locate the helper library.

Ensure that the helper library is available at the path: $path
Run `dart jni:setup` to generate the shared library if it does not exist.

Note: If the --build-path option is passed to jni:setup, Jni.spawn must be
called with same dylibDir. Also when creating new Dart isolates, Jni.setDylibDir
must be called.
''';
}

/// Error thrown when loading a dynamic library fails.
final class DynamicLibraryLoadError extends Error {
  /// The path to the dynamic library that failed to load.
  final String libraryPath;

  /// Creates a [DynamicLibraryLoadError] for the given [libraryPath].
  DynamicLibraryLoadError(this.libraryPath);

  @override
  String toString() {
    return '''
Failed to load dynamic library at path: $libraryPath
The library was found at the specified path, but it could not be loaded. 
This might be due to missing dependencies or incorrect file permissions. 
Please ensure ${Platform.isWindows ? r'that `\bin\server\jvm.dll` is in the PATH, and ' : ''}that the file has the correct permissions.

''';
  }
}

/// Exception thrown when converting a Dart string to a Java string fails.
final class JniNewStringException implements Exception {
  /// The string that failed to convert.
  final String string;

  /// Creates a [JniNewStringException] for the given [string].
  JniNewStringException(this.string);

  @override
  String toString() => 'Failed to convert string to a JString: $string';
}

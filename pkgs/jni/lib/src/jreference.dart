// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart' show internal;

import 'errors.dart';
import 'jni.dart';
import 'third_party/generated_bindings.dart';

@internal
extension ProtectedJReference on JReference {
  void setAsReleased() {
    _setAsReleased();
  }

  /// Similar to [pointer].
  ///
  /// Detaches the finalizer so the underlying pointer will not be deleted.
  JObjectPtr toPointer() {
    _setAsReleased();
    return _finalizable.pointer;
  }
}

/// A thin wrapper around a pointer that makes it [Finalizable].
@pragma('vm:deeply-immutable')
final class _JFinalizable implements Finalizable {
  final Pointer<Void> pointer;

  _JFinalizable(this.pointer);
}

@pragma('vm:deeply-immutable')
abstract final class JReference implements Finalizable {
  final _JFinalizable _finalizable;

  JReference._(this._finalizable);

  /// The underlying JNI reference.
  ///
  /// Throws [UseAfterReleaseError] if the object is previously released.
  ///
  /// Be careful when storing this in a variable since it might have gotten
  /// released upon use.
  JObjectPtr get pointer {
    if (isReleased) throw UseAfterReleaseError();
    return _finalizable.pointer;
  }

  /// Whether the underlying JNI reference is deleted or not.
  bool get isReleased;

  /// Whether the underlying JNI reference is `null` or not.
  bool get isNull;

  /// Deletes the underlying JNI reference and marks this as released.
  ///
  /// Releasing in one isolate while using or releasing in another isolate might
  /// crash in the JNI layer.
  ///
  /// Throws [DoubleReleaseError] if this is already released.
  ///
  /// Further uses of this object will throw [UseAfterReleaseError].
  void release() {
    _setAsReleased();
    _deleteReference();
  }

  void _deleteReference();

  void _setAsReleased();
}

/// A managed JNI global reference.
///
/// Uses a [NativeFinalizer] to delete the JNI global reference when finalized.
@pragma('vm:deeply-immutable')
final class JGlobalReference extends JReference {
  /// The finalizable handle that deletes [_JFinalizable.pointer].
  final Dart_FinalizableHandle _jobjectFinalizableHandle;
  final Pointer<Bool> _isReleased;
  final Pointer<Pointer<Char>> _releasedStackTracePointer;

  JGlobalReference._(super.finalizable, this._jobjectFinalizableHandle,
      this._isReleased, this._releasedStackTracePointer)
      : super._();

  factory JGlobalReference(Pointer<Void> pointer) {
    final finalizable = _JFinalizable(pointer);
    final isReleased = calloc<Bool>();
    var releasedStackTracePointer = nullptr.cast<Pointer<Char>>();
    final jobjectFinalizableHandle =
        InternalJniExtension.newJObjectFinalizableHandle(
            finalizable, finalizable.pointer, JObjectRefType.JNIGlobalRefType);
    InternalJniExtension.newBooleanFinalizableHandle(finalizable, isReleased);
    assert(() {
      releasedStackTracePointer = calloc<Pointer<Char>>();
      InternalJniExtension.newStackTraceFinalizableHandle(
          finalizable, releasedStackTracePointer.cast());
      return true;
    }());
    return JGlobalReference._(finalizable, jobjectFinalizableHandle, isReleased,
        releasedStackTracePointer);
  }

  @override
  bool get isNull => pointer == nullptr;

  @override
  JObjectPtr get pointer {
    if (isReleased) {
      throw UseAfterReleaseError(_releasedStackTrace);
    }
    return _finalizable.pointer;
  }

  void _appendToStackTrace(String stackTrace) {
    final previousStackTrace = _releasedStackTrace ?? '';
    final nativeStr = '$previousStackTrace$stackTrace'.toNativeUtf8();
    if (_releasedStackTracePointer != nullptr) {
      malloc.free(_releasedStackTracePointer.value);
    }
    _releasedStackTracePointer.value = nativeStr.cast();
  }

  @override
  void _setAsReleased() {
    if (isReleased) {
      throw DoubleReleaseError(_releasedStackTrace);
    }
    _isReleased.value = true;
    InternalJniExtension.deleteFinalizableHandle(
        _jobjectFinalizableHandle, _finalizable);
    assert(() {
      if (Jni.captureStackTraceOnRelease) {
        _appendToStackTrace('Object was released at:\n${StackTrace.current}\n');
      }
      return true;
    }());
  }

  @internal
  void registeredInArena() {
    if (Jni.captureStackTraceOnRelease) {
      _appendToStackTrace(
          'Object was registered to be released by an arena at:\n'
          '${StackTrace.current}\n');
    }
  }

  String? get _releasedStackTrace {
    if (_releasedStackTracePointer.value != nullptr) {
      return _releasedStackTracePointer.value.cast<Utf8>().toDartString();
    }
    return null;
  }

  @override
  void _deleteReference() {
    Jni.env.DeleteGlobalRef(_finalizable.pointer);
  }

  @override
  bool get isReleased => _isReleased.value;
}

final JReference jNullReference = _JNullReference();

@pragma('vm:deeply-immutable')
final class _JNullReference extends JReference {
  _JNullReference() : super._(_JFinalizable(nullptr));

  @override
  bool get isReleased => false;

  @override
  void _deleteReference() {
    // No need to delete `null`.
  }

  @override
  void _setAsReleased() {
    // No need to release `null`.
  }

  @override
  bool get isNull => true;
}

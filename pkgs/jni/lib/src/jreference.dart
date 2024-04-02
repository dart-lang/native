// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:jni/src/third_party/generated_bindings.dart';

import 'errors.dart';
import 'jni.dart';

extension ProtectedJReference on JReference {
  void setAsReleased() {
    _setAsReleased();
  }

  void ensureNotNull() {
    if (isNull) {
      throw JNullError();
    }
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
abstract final class JReference {
  final _JFinalizable _finalizable;

  JReference(this._finalizable);

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

  JGlobalReference._(
      super._finalizable, this._jobjectFinalizableHandle, this._isReleased);

  factory JGlobalReference(Pointer<Void> pointer) {
    final finalizable = _JFinalizable(pointer);
    final isReleased = calloc<Bool>();
    final jobjectFinalizableHandle =
        ProtectedJniExtensions.newJObjectFinalizableHandle(
            finalizable, finalizable.pointer, JObjectRefType.JNIGlobalRefType);
    ProtectedJniExtensions.newBooleanFinalizableHandle(finalizable, isReleased);
    return JGlobalReference._(
        finalizable, jobjectFinalizableHandle, isReleased);
  }

  @override
  bool get isNull => pointer == nullptr;

  @override
  void _setAsReleased() {
    if (isReleased) {
      throw DoubleReleaseError();
    }
    _isReleased.value = true;
    ProtectedJniExtensions.deleteFinalizableHandle(
        _jobjectFinalizableHandle, _finalizable);
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
  _JNullReference() : super(_JFinalizable(nullptr));

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

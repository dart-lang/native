// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:jni/src/third_party/generated_bindings.dart';

import 'errors.dart';
import 'jni.dart';

extension ProtectedJReference on JReference {
  void setAsReleased() {
    ProtectedJniExtensions.deleteFinalizableHandle(
        _finalizableHandle, _finalizable);
    // FIXME: No [DoubleReleaseError] will be thrown.
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
    setAsReleased();
    return _finalizable._pointer;
  }
}

@pragma('vm:deeply-immutable')
final class _JFinalizable implements Finalizable {
  final Pointer<Void> _pointer;

  _JFinalizable(this._pointer);
}

@pragma('vm:deeply-immutable')
abstract final class JReference {
  final _JFinalizable _finalizable;
  final Dart_FinalizableHandle _finalizableHandle;

  JReference(this._finalizable, int kind)
      : _finalizableHandle = ProtectedJniExtensions.newFinalizableHandle(
            _finalizable, _finalizable._pointer, kind);

  /// The underlying JNI reference.
  ///
  /// Throws [UseAfterReleaseError] if the object is previously released.
  ///
  /// Be careful when storing this in a variable since it might have gotten
  /// released upon use.
  JObjectPtr get pointer {
    // FIXME: No [UseAfterReleaseError] will be thrown.
    return _finalizable._pointer;
  }

  /// Whether the underlying JNI reference is deleted or not.
  // FIXME: releasing does not work.
  bool get isReleased => false;

  /// Whether the underlying JNI reference is `null` or not.
  bool get isNull;

  /// Deletes the underlying JNI reference and marks this as released.
  ///
  /// Throws [DoubleReleaseError] if this is already released.
  ///
  /// Further uses of this object will throw [UseAfterReleaseError].
  void release() {
    setAsReleased();
    _deleteReference();
  }

  void _deleteReference();
}

/// A managed JNI global reference.
///
/// Uses a [NativeFinalizer] to delete the JNI global reference when finalized.
@pragma('vm:deeply-immutable')
final class JGlobalReference extends JReference {
  JGlobalReference(Pointer<Void> pointer)
      : super(_JFinalizable(pointer), JObjectRefType.JNIGlobalRefType);

  @override
  bool get isNull => pointer == nullptr;

  @override
  void _deleteReference() {
    Jni.env.DeleteGlobalRef(_finalizable._pointer);
  }
}

final JReference jNullReference = _JNullReference();

@pragma('vm:deeply-immutable')
final class _JNullReference extends JReference {
  _JNullReference()
      : super(_JFinalizable(nullptr), JObjectRefType.JNIInvalidRefType);

  @override
  void _deleteReference() {
    // No need to delete `null`.
  }

  @override
  void release() {
    // No need to release `null`.
  }

  @override
  bool get isNull => true;
}

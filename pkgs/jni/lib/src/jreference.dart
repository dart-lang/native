// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:jni/src/third_party/generated_bindings.dart';

import 'errors.dart';
import 'jni.dart';

extension ProtectedJReference on JReference {
  void setAsReleased() {
    if (_released) {
      throw DoubleReleaseError();
    }
    _released = true;
    JGlobalReference._finalizer.detach(this);
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
    return _pointer;
  }
}

sealed class JReference {
  final JObjectPtr _pointer;
  bool _released = false;

  JReference(this._pointer);

  /// The underlying JNI reference.
  ///
  /// Throws [UseAfterReleaseError] if the object is previously released.
  ///
  /// Be careful when storing this in a variable since it might have gotten
  /// released upon use.
  JObjectPtr get pointer {
    if (_released) throw UseAfterReleaseError();
    return _pointer;
  }

  /// Whether the underlying JNI reference is deleted or not.
  bool get isReleased => _released;

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
class JGlobalReference extends JReference implements Finalizable {
  static final _finalizer =
      NativeFinalizer(Jni.env.ptr.ref.DeleteGlobalRef.cast());

  JGlobalReference(super._reference) {
    _finalizer.attach(this, _pointer, detach: this);
  }

  @override
  bool get isNull => pointer == nullptr;

  @override
  void _deleteReference() {
    Jni.env.DeleteGlobalRef(_pointer);
  }
}

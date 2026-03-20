// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:typed_data';

import '../core_bindings.dart';
import '../jarray.dart';
import '../jni.dart';
import '../jreference.dart';

extension JByteBufferExtension on JByteBuffer {
  /// Reads the byte at this buffer's current [position], and then increments
  /// the [position].
  ///
  /// Throws:
  ///  * `BufferOverflowException` - If the buffer's current [position] is not
  ///    smaller than its [limit]
  int get nextByte {
    return JByteBuffer$$Methods(this).get();
  }

  /// Writes the given byte into this buffer at the current [position], and then
  /// increments the [position].
  ///
  /// Throws:
  /// * `BufferOverflowException` - If this buffer's current [position] is not
  ///   smaller than its [limit]
  /// * `ReadOnlyBufferException` - If this buffer is read-only
  set nextByte(int b) {
    JByteBuffer$$Methods(this).put(b)?.release();
  }

  JByteArray get jArray {
    return array$1()!.as(JByteArray.type);
  }

  void _ensureIsDirect() {
    if (!isDirect) {
      throw StateError(
        'The buffer must be created with `JByteBuffer.allocateDirect`.',
      );
    }
  }

  Pointer<Void> _directBufferAddress() {
    final address = Jni.env.GetDirectBufferAddress(reference.pointer);
    if (address == nullptr) {
      throw StateError(
        'The memory region is undefined or '
        'direct buffer access is not supported by this JVM.',
      );
    }
    return address;
  }

  int _directBufferCapacity() {
    final capacity = Jni.env.GetDirectBufferCapacity(reference.pointer);
    if (capacity == -1) {
      throw StateError(
        'The object is an unaligned view buffer and the processor '
        'architecture does not support unaligned access.',
      );
    }
    return capacity;
  }

  Uint8List _asUint8ListUnsafe() {
    _ensureIsDirect();
    final address = _directBufferAddress();
    final capacity = _directBufferCapacity();
    return address.cast<Uint8>().asTypedList(capacity);
  }

  /// Returns this byte buffer as a [Uint8List].
  ///
  /// If [releaseOriginal] is `true`, this byte buffer will be released.
  ///
  /// Throws [StateError] if the buffer is not direct
  /// (see [JByteBuffer.allocateDirect]) or the JVM does not support the direct
  /// buffer operations or the object is an unaligned view buffer and
  /// the processor does not support unaligned access.
  Uint8List asUint8List({bool releaseOriginal = false}) {
    _ensureIsDirect();
    final address = _directBufferAddress();
    final capacity = _directBufferCapacity();
    final token = releaseOriginal
        ? reference.pointer
        : Jni.env.NewGlobalRef(reference.pointer);
    if (releaseOriginal) {
      reference.setAsReleased();
    }
    return address.cast<Uint8>().asTypedList(
          capacity,
          token: token,
          finalizer: Jni.env.ptr.ref.DeleteGlobalRef.cast(),
        );
  }
}

extension Uint8ListToJava on Uint8List {
  /// Creates a [JByteBuffer] from the content of this list.
  ///
  /// The [JByteBuffer] will be allocated using [JByteBuffer.allocateDirect].
  JByteBuffer toJByteBuffer() {
    final buffer = JByteBuffer.allocateDirect(length)!;
    buffer._asUint8ListUnsafe().setAll(0, this);
    return buffer;
  }
}

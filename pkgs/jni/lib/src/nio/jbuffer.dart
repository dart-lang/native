// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../core_bindings.dart' as core_bindings;
import '../jobject.dart';

export '../core_bindings.dart' show JBuffer, JBuffer$$Methods;

extension JBufferExtension on core_bindings.JBuffer {
  /// The number of elements this buffer contains.
  ///
  /// It is never negative and never changes.
  int get jCapacity => core_bindings.JBuffer$$Methods(this).capacity();

  /// The index of the next element to be read or written.
  ///
  /// It is never negative and is never greater than its [limit].
  int get jPosition => core_bindings.JBuffer$$Methods(this).position();

  /// Throws:
  /// * `IllegalArgumentException` - If the preconditions on [newPosition] do
  ///   not hold.
  set jPosition(int newPosition) {
    core_bindings.JBuffer$$Methods(this).position$1(newPosition)?.release();
  }

  /// The index of the first element that should not be read or written.
  ///
  /// It is never negative and is never greater than its [capacity].
  int get jLimit => core_bindings.JBuffer$$Methods(this).limit();

  /// Throws:
  /// * `IllegalArgumentException` - If the preconditions on [newLimit] do not
  ///   hold.
  set jLimit(int newLimit) {
    core_bindings.JBuffer$$Methods(this).limit$1(newLimit)?.release();
  }

  /// Sets this buffer's mark at its [position].
  ///
  /// Mark is the index to which its [position] will be reset when the [reset]
  /// method is invoked.
  void mark() {
    core_bindings.JBuffer$$Methods(this).mark()?.release();
  }

  /// Resets this buffer's [position] to the previously-marked position.
  ///
  /// Throws:
  /// * `InvalidMarkException` - If the mark has not been set
  void reset() {
    core_bindings.JBuffer$$Methods(this).reset()?.release();
  }

  /// Clears this buffer.
  ///
  /// The [position] is set to zero, the [limit] is set to
  /// the [capacity], and the mark is discarded.
  void clear() {
    core_bindings.JBuffer$$Methods(this).clear()?.release();
  }

  /// Flips this buffer.
  ///
  /// The limit is set to the current [position] and then the [position] is set
  /// to zero. If the mark is defined then it is discarded.
  void flip() {
    core_bindings.JBuffer$$Methods(this).flip()?.release();
  }

  /// Rewinds this buffer.
  ///
  /// The [position] is set to zero and the mark is discarded.
  void rewind() {
    core_bindings.JBuffer$$Methods(this).rewind()?.release();
  }

  /// The number of elements between the current [position] and the
  /// [limit].
  int get jRemaining => core_bindings.JBuffer$$Methods(this).remaining();

  /// Whether there are any elements between the current [position] and
  /// the [limit].
  bool get jHasRemaining => core_bindings.JBuffer$$Methods(this).hasRemaining();

  /// Whether or not this buffer is read-only.
  bool get jIsReadOnly => core_bindings.JBuffer$$Methods(this).isReadOnly();

  /// Whether or not this buffer is backed by an accessible array.
  bool get jHasArray => core_bindings.JBuffer$$Methods(this).hasArray();

  /// The array that backs this buffer.
  ///
  /// Note that the first element of the buffer starts at element [arrayOffset]
  /// of the backing array.
  ///
  /// Concrete subclasses like [JByteBuffer] provide more strongly-typed return
  /// values for this method.
  ///
  /// Invoke the [hasArray] method before invoking this method in order to
  /// ensure that this buffer has an accessible backing array.
  ///
  /// Throws:
  /// * `ReadOnlyBufferException` - If this buffer is backed by an array but is
  ///   read-only
  /// * `UnsupportedOperationException` - If this buffer is not backed by an
  ///   accessible array
  JObject get jArray => core_bindings.JBuffer$$Methods(this).array()!;

  /// The offset within this buffer's backing array of the first element
  /// of the buffer.
  ///
  /// Invoke the [hasArray] method before invoking this method in order to
  /// ensure that this buffer has an accessible backing array.
  ///
  /// Throws:
  /// * `ReadOnlyBufferException` - If this buffer is backed by an array but is
  ///   read-only
  /// * `UnsupportedOperationException` - If this buffer is not backed by an
  ///   accessible array
  int get jArrayOffset => core_bindings.JBuffer$$Methods(this).arrayOffset();

  /// Whether or not this buffer is direct.
  bool get jIsDirect => core_bindings.JBuffer$$Methods(this).isDirect();
}

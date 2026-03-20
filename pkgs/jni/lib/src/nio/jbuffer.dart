// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../core_bindings.dart';
import '../jobject.dart';

extension JBufferExtension on JBuffer {
  /// The number of elements this buffer contains.
  ///
  /// It is never negative and never changes.
  int get jCapacity => capacity();

  /// The index of the next element to be read or written.
  ///
  /// It is never negative and is never greater than its [limit].
  int get jPosition => position();

  /// Throws:
  /// * `IllegalArgumentException` - If the preconditions on [newPosition] do
  ///   not hold.
  set jPosition(int newPosition) {
    position$1(newPosition)?.release();
  }

  /// The index of the first element that should not be read or written.
  ///
  /// It is never negative and is never greater than its [capacity].
  int get jLimit => limit();

  /// Throws:
  /// * `IllegalArgumentException` - If the preconditions on [newLimit] do not
  ///   hold.
  set jLimit(int newLimit) {
    limit$1(newLimit)?.release();
  }

  /// Sets this buffer's mark at its [position].
  ///
  /// Mark is the index to which its [position] will be reset when the [reset]
  /// method is invoked.
  void mark() {
    JBuffer$$Methods(this).mark()?.release();
  }

  /// Resets this buffer's [position] to the previously-marked position.
  ///
  /// Throws:
  /// * `InvalidMarkException` - If the mark has not been set
  void reset() {
    JBuffer$$Methods(this).reset()?.release();
  }

  /// Clears this buffer.
  ///
  /// The [position] is set to zero, the [limit] is set to
  /// the [capacity], and the mark is discarded.
  void clear() {
    JBuffer$$Methods(this).clear()?.release();
  }

  /// Flips this buffer.
  ///
  /// The limit is set to the current [position] and then the [position] is set
  /// to zero. If the mark is defined then it is discarded.
  void flip() {
    JBuffer$$Methods(this).flip()?.release();
  }

  /// Rewinds this buffer.
  ///
  /// The [position] is set to zero and the mark is discarded.
  void rewind() {
    JBuffer$$Methods(this).rewind()?.release();
  }

  /// The number of elements between the current [position] and the
  /// [limit].
  int get jRemaining => remaining();

  /// Whether there are any elements between the current [position] and
  /// the [limit].
  bool get jHasRemaining => hasRemaining();

  /// Whether or not this buffer is read-only.
  bool get jIsReadOnly => isReadOnly;

  /// Whether or not this buffer is backed by an accessible array.
  bool get jHasArray => hasArray();

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
  JObject get jArray => array()!;

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
  int get jArrayOffset => arrayOffset();

  /// Whether or not this buffer is direct.
  bool get jIsDirect => isDirect;
}

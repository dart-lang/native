// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

typedef PosixMallocNative = Pointer Function(IntPtr);

@Native<PosixMallocNative>(symbol: 'malloc')
external Pointer posixMalloc(int size);

typedef PosixCallocNative = Pointer Function(IntPtr num, IntPtr size);

@Native<PosixCallocNative>(symbol: 'calloc')
external Pointer posixCalloc(int num, int size);

typedef PosixFreeNative = Void Function(Pointer);

@Native<Void Function(Pointer)>(symbol: 'free')
external void posixFree(Pointer ptr);

final Pointer<NativeFunction<PosixFreeNative>> posixFreePointer =
    Native.addressOf(posixFree);

// Note that ole32.dll is the correct name in both 32-bit and 64-bit.
final DynamicLibrary ole32lib = DynamicLibrary.open('ole32.dll');

typedef WinCoTaskMemAllocNative = Pointer Function(Size);
typedef WinCoTaskMemAlloc = Pointer Function(int);
final WinCoTaskMemAlloc winCoTaskMemAlloc =
    ole32lib.lookupFunction<WinCoTaskMemAllocNative, WinCoTaskMemAlloc>(
        'CoTaskMemAlloc');

typedef WinCoTaskMemFreeNative = Void Function(Pointer);
typedef WinCoTaskMemFree = void Function(Pointer);
final Pointer<NativeFunction<WinCoTaskMemFreeNative>> winCoTaskMemFreePointer =
    ole32lib.lookup('CoTaskMemFree');
final WinCoTaskMemFree winCoTaskMemFree = winCoTaskMemFreePointer.asFunction();

/// Manages memory on the native heap.
///
/// Does not initialize newly allocated memory to zero. Use [CallocAllocator]
/// for zero-initialized memory on allocation.
///
/// For POSIX-based systems, this uses `malloc` and `free`. On Windows, it uses
/// `CoTaskMemAlloc` and `CoTaskMemFree`.
final class MallocAllocator implements Allocator {
  const MallocAllocator._();

  /// Allocates [byteCount] bytes of of unitialized memory on the native heap.
  ///
  /// For POSIX-based systems, this uses `malloc`. On Windows, it uses
  /// `CoTaskMemAlloc`.
  ///
  /// Throws an [ArgumentError] if the number of bytes or alignment cannot be
  /// satisfied.
  // TODO: Stop ignoring alignment if it's large, for example for SSE data.
  @override
  Pointer<T> allocate<T extends NativeType>(int byteCount, {int? alignment}) {
    Pointer<T> result;
    if (Platform.isWindows) {
      result = winCoTaskMemAlloc(byteCount).cast();
    } else {
      result = posixMalloc(byteCount).cast();
    }
    if (result.address == 0) {
      throw ArgumentError('Could not allocate $byteCount bytes.');
    }
    return result;
  }

  /// Releases memory allocated on the native heap.
  ///
  /// For POSIX-based systems, this uses `free`. On Windows, it uses
  /// `CoTaskMemFree`. It may only be used against pointers allocated in a
  /// manner equivalent to [allocate].
  @override
  void free(Pointer pointer) {
    if (Platform.isWindows) {
      winCoTaskMemFree(pointer);
    } else {
      posixFree(pointer);
    }
  }

  /// Returns a pointer to a native free function.
  ///
  /// This function can be used to release memory allocated by [allocate]
  /// from the native side. It can also be used as a finalization callback
  /// passed to `NativeFinalizer` constructor or `Pointer.atTypedList`
  /// method.
  ///
  /// For example to automatically free native memory when the Dart object
  /// wrapping it is reclaimed by GC:
  ///
  /// ```dart
  /// class Wrapper implements Finalizable {
  ///   static final finalizer = NativeFinalizer(malloc.nativeFree);
  ///
  ///   final Pointer<Uint8> data;
  ///
  ///   Wrapper() : data = malloc.allocate<Uint8>(length) {
  ///     finalizer.attach(this, data);
  ///   }
  /// }
  /// ```
  ///
  /// or to free native memory that is owned by a typed list:
  ///
  /// ```dart
  /// malloc.allocate<Uint8>(n).asTypedList(n, finalizer: malloc.nativeFree)
  /// ```
  ///
  Pointer<NativeFinalizerFunction> get nativeFree =>
      Platform.isWindows ? winCoTaskMemFreePointer : posixFreePointer;
}

/// Manages memory on the native heap.
///
/// Does not initialize newly allocated memory to zero. Use [calloc] for
/// zero-initialized memory allocation.
///
/// For POSIX-based systems, this uses `malloc` and `free`. On Windows, it uses
/// `CoTaskMemAlloc` and `CoTaskMemFree`.
const MallocAllocator malloc = MallocAllocator._();

/// Manages memory on the native heap.
///
/// Initializes newly allocated memory to zero.
///
/// For POSIX-based systems, this uses `calloc` and `free`. On Windows, it uses
/// `CoTaskMemAlloc` and `CoTaskMemFree`.
final class CallocAllocator implements Allocator {
  const CallocAllocator._();

  /// Fills a block of memory with a specified value.
  void _fillMemory(Pointer destination, int length, int fill) {
    final ptr = destination.cast<Uint8>();
    for (var i = 0; i < length; i++) {
      ptr[i] = fill;
    }
  }

  /// Fills a block of memory with zeros.
  ///
  void _zeroMemory(Pointer destination, int length) =>
      _fillMemory(destination, length, 0);

  /// Allocates [byteCount] bytes of zero-initialized of memory on the native
  /// heap.
  ///
  /// For POSIX-based systems, this uses `malloc`. On Windows, it uses
  /// `CoTaskMemAlloc`.
  ///
  /// Throws an [ArgumentError] if the number of bytes or alignment cannot be
  /// satisfied.
  // TODO: Stop ignoring alignment if it's large, for example for SSE data.
  @override
  Pointer<T> allocate<T extends NativeType>(int byteCount, {int? alignment}) {
    Pointer<T> result;
    if (Platform.isWindows) {
      result = winCoTaskMemAlloc(byteCount).cast();
    } else {
      result = posixCalloc(byteCount, 1).cast();
    }
    if (result.address == 0) {
      throw ArgumentError('Could not allocate $byteCount bytes.');
    }
    if (Platform.isWindows) {
      _zeroMemory(result, byteCount);
    }
    return result;
  }

  /// Releases memory allocated on the native heap.
  ///
  /// For POSIX-based systems, this uses `free`. On Windows, it uses
  /// `CoTaskMemFree`. It may only be used against pointers allocated in a
  /// manner equivalent to [allocate].
  @override
  void free(Pointer pointer) {
    if (Platform.isWindows) {
      winCoTaskMemFree(pointer);
    } else {
      posixFree(pointer);
    }
  }

  /// Returns a pointer to a native free function.
  ///
  /// This function can be used to release memory allocated by [allocate]
  /// from the native side. It can also be used as a finalization callback
  /// passed to `NativeFinalizer` constructor or `Pointer.atTypedList`
  /// method.
  ///
  /// For example to automatically free native memory when the Dart object
  /// wrapping it is reclaimed by GC:
  ///
  /// ```dart
  /// class Wrapper implements Finalizable {
  ///   static final finalizer = NativeFinalizer(calloc.nativeFree);
  ///
  ///   final Pointer<Uint8> data;
  ///
  ///   Wrapper() : data = calloc.allocate<Uint8>(length) {
  ///     finalizer.attach(this, data);
  ///   }
  /// }
  /// ```
  ///
  /// or to free native memory that is owned by a typed list:
  ///
  /// ```dart
  /// calloc.allocate<Uint8>(n).asTypedList(n, finalizer: calloc.nativeFree)
  /// ```
  ///
  Pointer<NativeFinalizerFunction> get nativeFree =>
      Platform.isWindows ? winCoTaskMemFreePointer : posixFreePointer;
}

/// Manages memory on the native heap.
///
/// Initializes newly allocated memory to zero. Use [malloc] for uninitialized
/// memory allocation.
///
/// For POSIX-based systems, this uses `calloc` and `free`. On Windows, it uses
/// `CoTaskMemAlloc` and `CoTaskMemFree`.
const CallocAllocator calloc = CallocAllocator._();

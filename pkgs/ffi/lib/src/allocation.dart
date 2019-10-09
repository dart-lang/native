// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

// Note that kernel32.dll is the correct name in both 32-bit and 64-bit.
final DynamicLibrary stdlib = Platform.isWindows
    ? DynamicLibrary.open("kernel32.dll")
    : DynamicLibrary.process();

typedef PosixMallocNative = Pointer Function(IntPtr);
typedef PosixMalloc = Pointer Function(int);
final PosixMalloc posixMalloc =
    stdlib.lookupFunction<PosixMallocNative, PosixMalloc>("malloc");

typedef PosixFreeNative = Void Function(Pointer);
typedef PosixFree = void Function(Pointer);
final PosixFree posixFree =
    stdlib.lookupFunction<PosixFreeNative, PosixFree>("free");

typedef WinGetProcessHeapFn = Pointer Function();
final WinGetProcessHeapFn winGetProcessHeap = stdlib
    .lookupFunction<WinGetProcessHeapFn, WinGetProcessHeapFn>("GetProcessHeap");
final Pointer processHeap = winGetProcessHeap();

typedef WinHeapAllocNative = Pointer Function(Pointer, Uint32, IntPtr);
typedef WinHeapAlloc = Pointer Function(Pointer, int, int);
final WinHeapAlloc winHeapAlloc =
    stdlib.lookupFunction<WinHeapAllocNative, WinHeapAlloc>("HeapAlloc");

typedef WinHeapFreeNative = Int32 Function(
    Pointer heap, Uint32 flags, Pointer memory);
typedef WinHeapFree = int Function(Pointer heap, int flags, Pointer memory);
final WinHeapFree winHeapFree =
    stdlib.lookupFunction<WinHeapFreeNative, WinHeapFree>("HeapFree");

/// Allocates memory on the native heap.
///
/// For POSIX-based systems, this uses malloc. On Windows, it uses HeapAlloc
/// against the default public heap. Allocation of either element size or count
/// of 0 is undefined.
///
/// Throws an ArgumentError on failure to allocate.
Pointer<T> allocate<T extends NativeType>({int count = 1}) {
  final int totalSize = count * sizeOf<T>();
  Pointer<T> result;
  if (Platform.isWindows) {
    result = winHeapAlloc(processHeap, /*flags=*/ 0, totalSize).cast();
  } else {
    result = posixMalloc(totalSize).cast();
  }
  if (result.address == 0) {
    throw ArgumentError("Could not allocate $totalSize bytes.");
  }
  return result;
}

/// Releases memory on the native heap.
///
/// For POSIX-based systems, this uses free. On Windows, it uses HeapFree
/// against the default public heap. It may only be used against pointers
/// allocated in a manner equivalent to [allocate].
///
/// Throws an ArgumentError on failure to free.
///
// TODO(dartbug.com/36855): Once we have a ffi.Bool type we can use it instead
// of testing the return integer to be non-zero.
void free(Pointer pointer) {
  if (Platform.isWindows) {
    if (winHeapFree(processHeap, /*flags=*/ 0, pointer) == 0) {
      throw ArgumentError("Could not free $pointer.");
    }
  } else {
    posixFree(pointer);
  }
}

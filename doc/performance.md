# Performance with Native Code

How to assess performance of Dart and native code, and how to improve it.

## Profiling Performance


| Tool                                  | Platform  | Primary Use Case                        | Measures (Dart CPU)          | Measures (Native CPU)    | Measures (Dart Heap) | Measures (Native Heap)                                           |
| ------------------------------------- | --------- | --------------------------------------- | ---------------------------- | ------------------------ | -------------------- | ---------------------------------------------------------------- |
| Dart DevTools                         | All       | Profiles Dart VM, UI jank, Dart heap    | Yes                          | Opaque "Native" block    | Yes                  | Tracks "External" VM-aware memory only; Misses native-heap leaks |
| Xcode Instruments (Time Profiler)     | iOS/macOS | Profiles native CPU call stacks         | No                           | Yes (full symbolication) | No                   | No                                                               |
| Xcode Instruments (Leaks/Allocations) | iOS/macOS | Profiles native heap (malloc, mmap)     | No                           | No                       | No                   | Yes                                                              |
| Android Studio Profiler (CPU)         | Android   | Profiles native C/C++ CPU execution     | No                           | Yes (traces C++ calls)   | No                   | No                                                               |
| Perfetto (heapprofd)                  | Android   | Advanced native heap profiling          | No                           | No                       | No                   | Yes (traces malloc/free call stacks)                             |
| Linux perf                            | Linux     | Unified Dart AOT + Native CPU profiling | Yes (requires special flags) | Yes                      | No                   | No                                                               |

<!-- TODO: Add documentation for the other tools. -->

### Dart DevTools

For only assessing the performance of the Dart code, and treating native code as
a black box, use the Dart performance tooling.

See the documentation on https://dart.dev/tools/dart-devtools and
https://docs.flutter.dev/perf. For FFI, most specifically, you can use
https://docs.flutter.dev/tools/devtools/cpu-profiler and
https://docs.flutter.dev/tools/devtools/performance#timeline-events-tab.
For synchronous FFI calls you can add synchronous timeline events, and for
asynchronous code (using async callbacks or helper isolates) you can use async
events.

### `perf` On Linux

To see both Dart and native symbols in a flame graph, you can use `perf` on
Linux.

For JIT:

```
$ perf record -g out/DebugX64/dart-sdk/bin/dart --generate-perf-events-symbols benchmarks/FfiCall/dart/FfiCall.dart
```

For AOT, we currently don't have a [single command
yet](https://github.com/dart-lang/sdk/issues/54254). You need to use
`precompiler2` command from the Dart SDK:

```
$ pkg/vm/tool/precompiler2 --packages=.packages benchmarks/FfiCall/dart/FfiCall.dart benchmarks/FfiCall/dart/FfiCall.dart.bin && \
perf record -g pkg/vm/tool/dart_precompiled_runtime2 --generate-perf-events-symbols --profile-period=10000 benchmarks/FfiCall/dart/FfiCall.dart.bin
```

## Improving performance

There are some typical patterns to improve performance:

* To avoid dropped frames, move long-running FFI calls to a helper isolate.
* To avoid copying data where possible:
  * Keep data in native memory, operating on [`Pointer`][]s and using
    [`asTypedList`][] to convert the pointers into [`TypedData`][].
  * For short calls, if the memory is in Dart, avoid copying by using leaf calls
    ([`isLeaf`][], [`isLeaf` (2)][], [`isLeaf` (3)][]) and [`address`]. (Leaf
    calls prevent the Dart GC from running on all isolates, which allows giving
    a pointer to native code of an object in Dart.)
  * Use [`Isolate.exit`][] to send large data from a helper isolate to the main
    isolate after a large computation.
* For many small calls, limit the overhead per call. This makes a significant
  difference for calls shorter than 1 us (one millionth of a second), and can be
  considered for calls of up to 10 us.
  * Use leaf calls ([`isLeaf`][], [`isLeaf` (2)][], [`isLeaf` (3)][]).
  * Prefer using [build hooks][] with [`Native`] `external`
  functions over [`DynamicLibrary.lookupFunction`][] and
  [`Pointer.asFunction`][].
  
  For reference, this benchmark reports a 1000 FFI calls in AOT on Linux x64.
  ```
  FfiCall.Uint8x01(RunTime): 234.61104068226345 us.
  FfiCall.Uint8x01Leaf(RunTime): 71.9994712538334 us.
  FfiCall.Uint8x01Native(RunTime): 216.07292770828917 us.
  FfiCall.Uint8x01NativeLeaf(RunTime): 27.64136415181509 us.
  ```
  A single call that is native-leaf takes 28 ns, while an `asFunction`-non-leaf
  takes 235 ns. So for calls taking ~1000 ns that's a 20% speedup.

[`address`]: https://api.dart.dev/dart-ffi/StructAddress/address.html
[`asTypedList`]: https://api.dart.dev/dart-ffi/Uint8Pointer/asTypedList.html
[`DynamicLibrary.lookupFunction`]: https://api.dart.dev/dart-ffi/DynamicLibraryExtension/lookupFunction.html
[`isLeaf` (2)]: https://api.dart.dev/dart-ffi/NativeFunctionPointer/asFunction.html
[`isLeaf` (3)]:https://api.dart.dev/dart-ffi/DynamicLibraryExtension/lookupFunction.html
[`isLeaf`]: https://api.dart.dev/dart-ffi/Native/isLeaf.html
[`Isolate.exit`]: https://api.dart.dev/dart-isolate/Isolate/exit.html
[`Native`]: https://api.dart.dev/dart-ffi/Native-class.html
[`Pointer.asFunction`]: https://api.dart.dev/dart-ffi/NativeFunctionPointer/asFunction.html
[`Pointer`]: https://api.dart.dev/dart-ffi/Pointer-class.html
[`TypedData`]: https://api.dart.dev/dart-typed_data/TypedData-class.html
[build hooks]: https://dart.dev/tools/hooks



# Performance with Native Code

How to assess performance of Dart and native code, and how to improve it.

## Profiling Performance

| Tool                                    | Platform  | Primary Use Case                        | Measures (Dart CPU)          | Measures (Native CPU)    | Measures (Dart Heap) | Measures (Native Heap)                                           |
| --------------------------------------- | --------- | --------------------------------------- | ---------------------------- | ------------------------ | -------------------- | ---------------------------------------------------------------- |
| [Dart DevTools]                         | All       | Profiles Dart VM, UI jank, Dart heap    | Yes                          | Opaque "Native" block    | Yes                  | Tracks "External" VM-aware memory only; Misses native-heap leaks |
| [Xcode Instruments (Time Profiler)]     | iOS/macOS | Profiles native CPU call stacks         | No                           | Yes (full symbolication) | No                   | No                                                               |
| [Xcode Instruments (Leaks/Allocations)] | iOS/macOS | Profiles native heap (malloc, mmap)     | No                           | No                       | No                   | Yes                                                              |
| [Android Studio Profiler (CPU)]         | Android   | Profiles native C/C++ CPU execution     | No                           | Yes (traces C++ calls)   | No                   | No                                                               |
| [Perfetto (heapprofd)]                  | Android   | Advanced native heap profiling          | No                           | No                       | No                   | Yes (traces malloc/free call stacks)                             |
| [Linux perf]                            | Linux     | Unified Dart AOT + Native CPU profiling | Yes (requires special flags) | Yes                      | No                   | No                                                               |
| [Visual Studio CPU Usage Profiler]      | Windows   | Profiles native C/C++ CPU execution     | No                           | Yes (traces C++ calls)   | No                   | No                                                               |
| [WPA (Heap Analysis)]                   | Windows   | Advanced native heap profiling          | No                           | No                       | No                   | Yes (traces malloc/free call stacks)                             |

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

### `perf` on Linux

To see both Dart and native symbols in a flame graph, you can use `perf` on
Linux.

To run the [FfiCall benchmark] in JIT mode with `perf`:  

```
$ perf record -g dart --generate-perf-events-symbols benchmarks/FfiCall/dart/FfiCall.dart && \
perf report --hierarchy
```

Note that Flutter apps are deployed in AOT mode. So prefer profiling in AOT
mode.

For AOT, we currently don't have a [single command
yet](https://github.com/dart-lang/sdk/issues/54254). You need to use
`precompiler2` command from the Dart SDK. See [building the Dart SDK] for how to
build the Dart SDK.

```
$ pkg/vm/tool/precompiler2 benchmarks/FfiCall/dart/FfiCall.dart benchmarks/FfiCall/dart/FfiCall.dart.bin && \
perf record -g pkg/vm/tool/dart_precompiled_runtime2 --generate-perf-events-symbols benchmarks/FfiCall/dart/FfiCall.dart.bin && \
perf report --hierarchy
```

To analyze a performance issue in Flutter, it is best to reproduce the issue in
Dart standalone.

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
  
  For reference, the [FfiCall benchmark][] reports 1000 FFI calls in AOT on Linux x64:
  ```
  FfiCall.Uint8x01(RunTime): 234.61104068226345 us.
  FfiCall.Uint8x01Leaf(RunTime): 71.9994712538334 us.
  FfiCall.Uint8x01Native(RunTime): 216.07292770828917 us.
  FfiCall.Uint8x01NativeLeaf(RunTime): 27.64136415181509 us.
  ```
  A single call that is native-leaf takes 28 ns, while an `asFunction`-non-leaf
  takes 235 ns. So for calls taking ~1000 ns that's a 20% speedup.

## Community sources

* (Video) Using Dart FFI for Compute-Heavy Tasks:
  https://www.youtube.com/watch?v=eJR5C0VRCjU
* (Video) Maximize Speed with Dart FFI: Beginner’s Guide to High-Performance
  Integration https://www.youtube.com/watch?v=HF8gHAakb1Q

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
[Android Studio Profiler (CPU)]: https://developer.android.com/studio/profile
[build hooks]: https://dart.dev/tools/hooks
[building the Dart SDK]: https://github.com/dart-lang/sdk/blob/main/docs/Building.md
[Dart DevTools]: https://dart.dev/tools/dart-devtools
[FfiCall benchmark]: https://github.com/dart-lang/sdk/blob/main/benchmarks/FfiCall/dart/FfiCall.dart
[Linux perf]: https://perfwiki.github.io/main/
[Perfetto (heapprofd)]: https://perfetto.dev/
[Visual Studio CPU Usage Profiler]: https://learn.microsoft.com/en-us/visualstudio/profiling/cpu-usage
[WPA (Heap Analysis)]: https://learn.microsoft.com/en-us/windows-hardware/test/wpt/windows-performance-analyzer
[Xcode Instruments (Leaks/Allocations)]: https://developer.apple.com/documentation/xcode/gathering-information-about-memory-use
[Xcode Instruments (Time Profiler)]: https://developer.apple.com/tutorials/instruments

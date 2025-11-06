# Objective-C threading considerations

Multithreading is one of the trickiest parts of interop between Objective-C
and Dart. This is due to the relationship between Dart isolates and OS
threads, and the way Apple's APIs handle multithreading:

1. Dart isolates are not the same thing as threads. Isolates run on threads,
   but aren't guaranteed to run on any particular thread, and the VM might
   change which thread an isolate is running on without warning. There is an
   [open feature request](https://github.com/dart-lang/sdk/issues/46943)
   to enable isolates to be pinned to specific threads.
2. While FFIgen supports converting Dart functions to Objective-C blocks,
   most Apple APIs don't make any guarantees about which thread a callback
   will run on.
3. Most APIs that involve UI interaction can only be called on the main
   thread, also called the platform thread in Flutter.
4. Many Apple APIs are [not thread safe](
   https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/ThreadSafetySummary/ThreadSafetySummary.html).

The first two points mean that a block created in one isolate might be
invoked on a thread running a different isolate, or no isolate at all.
Depending on the type of block you are using, this could cause your app to
crash. When a block is created, the isolate it was created in is its owner.
Blocks created using `FooBlock.fromFunction` must be invoked on the
owner isolate's thread, otherwise they will crash. Blocks created using
`FooBlock.listener` or `FooBlock.blocking` can be safely invoked from any
thread, and the function they wrap will (eventually) be invoked inside the
owner isolate, though these constructors are only supported for blocks that
return `void`. `FooBlock.blocking` may add support for non-`void` return values
in future, if there is user demand for it.

The third point means that directly calling some Apple APIs using the
generated Dart bindings might be thread unsafe. This could crash your app, or
cause other unpredictable behavior. In recent versions of Flutter, the main
isolate runs on the platform thread, so this isn't an issue when invoking
these thread-locked APIs from the main isolate. If you need to invoke these
APIs from other isolates, or you need to support older versions of flutter,
you can use the [`runOnPlatformThread`](
https://api.flutter.dev/flutter/dart-ui/runOnPlatformThread.html) function.

Regarding the last point, although Dart isolates can switch threads, they
only ever run on one thread at a time. So, the API you are interacting with
doesn't necessarily have to be thread safe, as long as it is not thread
hostile, and doesn't have constraints about which thread it's called from.

You can safely interact with Objective-C code as long as you keep these
limitations in mind.

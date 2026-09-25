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
When a block is created in Dart, the isolate it was created in is its owner.
The block is permanently tied to that isolate, and the Dart function it wraps
will always be executed on the owner isolate.

> [!IMPORTANT]
> Depending on the type of block you are using, invoking it on the wrong thread
> could cause your app to crash. If possible, you should use a `.listener`
> or `.blocking` block to avoid this issue.

- Blocks created using `FooBlock.fromFunction` must be invoked on the
  owner isolate's thread, otherwise they will crash. If the block is invoked
  after the owner isolate has shut down, it will also crash.
- Blocks created using `FooBlock.listener` can safely be invoked from any
  thread. These blocks are asynchronous, and the Dart function will be invoked
  on the owner isolate at a later time. Return values are not supported, so
  this constructor is only code generated for blocks that return `void`. If the
  owner isolate shuts down before the block is invoked, the invocation will be
  silently ignored.
- Blocks created using `FooBlock.blocking` can be safely invoked from any
  thread, and the Dart function will be invoked on the owner isolate.
  The caller will be blocked until the Dart function has completed. If the
  owner isolate shuts down before the block is invoked, the invocation will be
  silently ignored. Return values are not currently supported, but it would
  be possible to add support for non-`void` blocking blocks, if there is
  user demand for it.

The third point means that directly calling some Apple APIs using the
generated Dart bindings might be thread unsafe. This could crash your app, or
cause other unpredictable behavior. In recent versions of Flutter, the main
isolate runs on the platform thread, so this isn't an issue when invoking
these thread-locked APIs from the main isolate. If you need to invoke these
APIs from other isolates, or you need to support older versions of flutter,
you can use the [`runOnPlatformThread`](
https://api.flutter.dev/flutter/dart-ui/runOnPlatformThread.html) function.

Regarding the fourth point, although Dart isolates can switch threads, they
only ever run on one thread at a time. So, the API you are interacting with
doesn't necessarily have to be thread safe, as long as it is not thread
hostile, and doesn't have constraints about which thread it's called from.

You can safely interact with Objective-C code as long as you keep these
limitations in mind.

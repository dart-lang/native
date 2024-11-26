## Threading considerations

Unlike method channels, JNIgen uses FFI calls. This means that the calls happen
on the calling thread.

### Deadlocks

When implementing Java/Kotlin interfaces in Dart, it is possible to create
deadlocks. Suppose we have created an object that implements `Runnable` in Dart
in the main isolate. This means that the code will always be run on the platform
thread.

```dart
// Dart
final runnableFromDart = Runnable.implement(
  $Runnable(run: () => print('hello'))
);
```

If Java creates a second thread from the platform thread and calls
`runnableFromDart.run()` from that thread and then attempts to join or
synchronize with the main thread, it will cause a deadlock.

This is because the body of the `runnableFromDart` needs to be run on the
platform thread, so JNIgen waits until platform thread is available. However in
this setting the platform thread will not be available until
`runnableFromDart.run` is executed.

If the callback does not need to be blocking,
[making it a listener](../interface_implementation.md#implement-as-a-listener)
solves this issue:

```dart
// Dart
final runnableFromDart = Runnable.implement($Runnable(
  run: () => print('hello'),
  run$async: true,
));
```

Of course, only void-returning methods can be non-blocking.

### Dart-standalone

On Dart-standalone, call `Jni.setDylibsDir` in each new isolate, since each
isolate loads the dynamic libararies separately.

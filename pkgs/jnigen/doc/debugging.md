# Debugging

## Memory Management Issues

When working with JNI, you might encounter memory management errors such as
`DoubleReleaseError` or `UseAfterReleaseError`. These occur when you try to
release an object that has already been released, or use an object after it has
been released.

By default, these errors might not provide enough context to identify where the
object was originally released. To help with debugging, `package:jni` provides a
flag to capture the stack trace when an object is released.

### `Jni.captureStackTraceOnRelease`

You can enable stack trace capturing by setting
`Jni.captureStackTraceOnRelease = true`.

```dart
import 'package:jni/jni.dart';

void main() {
  // ... Initialization code ...
  // Enable stack trace capturing for debugging
  Jni.captureStackTraceOnRelease = true;

  final s = 'hello'.toJString();
  s.release(); // The stack trace is captured here.

  // ...

  s.release(); // Throws DoubleReleaseError
}
```

When this flag is enabled, the `DoubleReleaseError` or `UseAfterReleaseError`
will include the stack trace of the call that originally released the object.

**Example Output:**

```
Bad state: Double release error
Object was released at:
#0      ...
...
```

> [!NOTE] Capturing stack traces has a performance cost and is implemented using
> `assert`. Therefore, it **only works in debug mode** (when assertions are
> enabled). It defaults to `false`.

### Arena Stack Traces

If you use `using` (from `package:ffi`) and `releasedBy`, the stack trace will
also include where the object was registered to be released.

```dart
using((arena) {
  final s = 'hello'.toJString()..releasedBy(arena);
  // ...
});
```

If `DoubleReleaseError` or `UseAfterReleaseError` occurs, the output will show
both where it was released and where it was registered in the arena.

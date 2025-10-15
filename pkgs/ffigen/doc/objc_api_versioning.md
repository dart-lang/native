# Dealing with Objective-C API versioning

Objective-C uses the `@available` annotation to allow developers to write `if`
statements that do different things on different OS versions. It also generates
a compiler warning if the developer uses an API that is only available in
particular OS versions, without guarding it with an `@available` if statement.

```obj-c
if (@available(iOS 18, *)) {
  // Use newer iOS 18 API.
} else {
  // Fallback to old API.
}
```

We can't replicate the compiler warning in Dart/FFIgen at the moment, but we
can write the runtime version check. The recommended way of doing this is using
`package:objective_c`'s `checkOsVersion`:

```dart
// If you only need to support iOS:
if (checkOsVersion(iOS: Version(18, 0, 0))) {
  // Use newer iOS 18 API.
} else {
  // Fallback to old API.
}

// If you need to support iOS and macOS:
if (checkOsVersion(iOS: Version(18, 0, 0), macOS: Version(15, 3, 0))) {
  // Use newer API available in iOS 18 and macOS 15.3.
} else {
  // Fallback to old API.
}
```

`checkOsVersion` returns `true` if the current OS version is equal to or greater
than the given version.

FFIgen's generated code includes version checks that will throw an
`OsVersionError` if the API is not available in the current OS version. But it's
better to write if statements like above, rather than trying to catch this
error.

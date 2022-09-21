[![Build Status](https://github.com/dart-lang/jnigen/workflows/Dart%20CI/badge.svg)](https://github.com/dart-lang/jnigen/actions?query=workflow%3A%22Dart+CI%22+branch%3Amain)

## jnigen

This project intends to provide 2 packages to enable JNI interop from Dart & Flutter. Currently this package is highly experimental.

| Package | Description |
| ------- | --------- |
| [jni](jni/) | Ergonomic C bindings to JNI C API and several helper methods |
| [jnigen](jnigen/) | Tool to generate Dart bindings to Java code using FFI |

This is a work-in-progress project under Google Summer of Code 2022 program.

## SDK Requirements
Dart standalone target is supported, but due to some problems with pubspec, the `dart` command must be from Flutter SDK and not Dart SDK. See [dart-lang/pub#3563](https://github.com/dart-lang/pub/issues/3563).

On windows, you need to append the path of `jvm.dll` in your JDK installation to PATH.

For example, on Powershell:

```
$env:Path += ";${env:JAVA_HOME}\bin\server".
```
(If JAVA_HOME not set, find the `java.exe` executable and set the environment variable in Control Panel).

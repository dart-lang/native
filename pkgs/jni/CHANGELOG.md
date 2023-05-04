## 0.5.0-dev.0
* **Breaking Change** ([#137](https://github.com/dart-lang/jnigen/issues/137)): Java primitive types are now all lowercase like `jint`, `jshort`, ...
* The bindings for `java.util.Set`, `java.util.Map`, `java.util.List` and the numeric types like `java.lang.Integer`, `java.lang.Boolean`, ... are now included in `package:jni`.

## 0.4.0
* Type classes now have `superCount` and `superType` getters used for type inference.

## 0.3.0
* Added `PortContinuation` used for `suspend fun` in Kotlin.
* `dartjni` now depends on `dart_api_dl.h`.

## 0.2.1
* Added `.clang-format` to pub.

## 0.2.0
* Added array support
* Added generic support
* `JniX` turned into `JX` for a more terse code.

## 0.1.1
* Windows support for running tests and examples on development machines.

## 0.1.0
* Initial version: Android and Linux support, JObject API


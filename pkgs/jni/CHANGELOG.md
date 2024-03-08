## 0.8.0-wip

- **Breaking Change**: `JObject.reference` now returns a `JReference` instead of
  `Pointer<Void>`.
- **Breaking Change** ([#548](https://github.com/dart-lang/native/issues/548)):
  Converted various `Exception`s into `Error`s:
  - `UseAfterReleaseException` -> `UseAfterReleaseError`
  - `DoubleReleaseException` -> `DoubleReleaseError`
  - `SpawnException` -> `JniError` (It's now a `sealed class`)
  - `JNullException` -> `JNullError`
  - `InvalidCallTypeException` -> `InvalidCallTypeError`
  - `HelperNotFoundException` -> `HelperNotFoundError`
  - `JvmExistsException` -> `JniVmExistsError`
  - `NoJvmInstanceException` -> `NoJvmInstanceError`
- **Breaking Change**: Removed `InvalidJStringException`.
- **Breaking Change**: The default return `callType` of type parameter `int` for
  methods such as `JObject.callMethodByName<int>` is now Java's `long` instead
  of `int` to be consistent with the way arguments work.
- **Breaking Change**: `JType` is now `sealed`.
- **Breaking Change**: Primitive types and their type classes are now `final`.
- **Breaking Change**: `JArray.filled` now uses the generated type class of the
  `fill` object and not its Java runtime type.

## 0.7.2
- Fixed a bug where reading non-null terminated strings would overflow.

## 0.7.1
- Removed macOS Flutter plugin until package:jni supports it ([#780](https://github.com/dart-lang/native/issues/780)).

## 0.7.0

- **Breaking Change** ([#563](https://github.com/dart-lang/native/issues/563)):
  Added `JBuffer` and `JByteBuffer` classes as default classes for
  `java.nio.Buffer` and `java.nio.ByteBuffer` respectively.
- **Breaking Change**: Made the type classes `final`.
- Fixed a bug where `addAll`, `removeAll` and `retainAll` in `JSet` would run
  their respective operation twice.
- Fixed a bug where `JList.insertAll` would not throw the potentially thrown
  Java exception.

## 0.6.1

- Depend on the stable version of Dart 3.1.

## 0.6.0

- **Breaking Change** ([#707](https://github.com/dart-lang/native/issues/707)):
  Renamed `delete*` to `release*`.
- Added `PortProxy` and related methods used for interface implementation.
- Added the missing binding for `java.lang.Character`.

## 0.5.0

- **Breaking Change** ([#711](https://github.com/dart-lang/native/issues/711)):
  Java primitive types are now all lowercase like `jint`, `jshort`, ...
- The bindings for `java.util.Set`, `java.util.Map`, `java.util.List` and the
  numeric types like `java.lang.Integer`, `java.lang.Boolean`, ... are now
  included in `package:jni`.

## 0.4.0

- Type classes now have `superCount` and `superType` getters used for type
  inference.

## 0.3.0

- Added `PortContinuation` used for `suspend fun` in Kotlin.
- `dartjni` now depends on `dart_api_dl.h`.

## 0.2.1

- Added `.clang-format` to pub.

## 0.2.0

- Added array support
- Added generic support
- `JniX` turned into `JX` for a more terse code.

## 0.1.1

- Windows support for running tests and examples on development machines.

## 0.1.0

- Initial version: Android and Linux support, JObject API

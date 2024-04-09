## 0.8.0

- **Breaking Change** ([#981](https://github.com/dart-lang/native/issues/981)):

  - `JObject.reference` now returns a `JReference` instead of `Pointer<Void>`.
  - `.fromRef` constructors are now called `.fromReference` and they take a
    `JReference` instead of `Pointer<Void>`.
  - `JObject` reflective field retrieving and method calling methods are
    removed. Use `JClass` API instead.
  - The following `Jni.accessors` methods have been removed:

    - `getClassOf`
    - `getMethodIDOf`
    - `getStaticMethodIDOf`
    - `getFieldIDOf`
    - `getStaticFieldIDOf`
    - `newObjectWithArgs`
    - `callMethodWithArgs`
    - `callStaticMethodWithArgs`

    Instead use the `JClass` API.

  - `Jni.findJClass` is replaced with `JClass.forName(String name)`
  - `JClass` has been refactored. Instead of directly calling methods, getting
    and setting fields, use `JClass.instanceMethodId`, `JClass.staticMethodId`,
    `JClass.constructorId`, `JClass.instanceFieldId`, and `JClass.staticFieldId`
    to first get access to the member.
  - Renamed `JObject.getClass()` to `JObject.jClass`.
  - Removed `Jni.deleteAllRefs`.

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
- **Breaking Change**: `JType` is now `sealed`.
- **Breaking Change**: Primitive types and their type classes are now `final`.
- **Breaking Change**: `JArray.filled` now uses the generated type class of the
  `fill` object and not its Java runtime type.
- `JObject`s now check the types using `instanceof` in debug mode when using
  `castTo`.
- **Breaking Change**: `Jni.initDLApi()` is removed.
- Added the ability to share `JObject`s across isolates.
  ```dart
  // This now works.
  final foo = 'foo'.toJString();
  Isolate.run(() {
    // `foo` is usable from another isolate.
    print(foo);
  });
  ```

## 0.7.3

- Fixed a bug where `get(Static)MethodID` and `get(Static)FieldID` could access
  null and throw.

## 0.7.2

- Fixed a bug where reading non-null terminated strings would overflow.

## 0.7.1

- Removed macOS Flutter plugin until package:jni supports it
  ([#780](https://github.com/dart-lang/native/issues/780)).

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

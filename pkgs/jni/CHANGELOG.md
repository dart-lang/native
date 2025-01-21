## 0.14.0-wip

- Added `DynamicLibraryLoadError` which is thrown when the dynamic library fails
  to load. `HelperNotFoundError` will only be thrown when the helper library
  cannot be found.
- Update the README.md to include info about generating bindings for built-in
  java types.
- Do not require a `dylibDir` when running `Jni.spawn` from Dart standalone,
  instead use the default value of `build/jni_libs`.

## 0.13.0

- **Breaking Change**: Separated primitive arrays from object arrays.
  Previously, a primitive array like an array of bytes was typed
  `JArray<jbyte>`. Now `JArray<T>` only accepts `JObject`s as types and
  primitive arrays like arrays of bytes have their own types such as
  `JByteArray`.

  This enables all arrays to implement `Iterable` which makes it possible to use
  them in a for-loop or use methods such as `map` on them.

- Added nullable type classes for all Java objects.
- Fixed a problem where interfaces implemented in Dart would crash when calling
  the default object methods: `equals`, `hashCode`, and `toString`.

## 0.12.2

- Added `JniUtils.fromReferenceAddress` which helps with sending `JObject`s
  through method channels. You can send the address of the pointer as `long` and
  reconstruct the class using the helper method.
- Fixed a bug where it would be possible for a type class inference to fail.
- Return 'null' when calling `toString` on a null object.

## 0.12.0

- **Breaking Change**: Renamed `castTo` to `as`.
- Renamed library `internal_helpers_for_jnigen` to `_internal`.
- Using 16KB page size to support Android 15.
- Added `JImplementer` which enables building an object that implements multiple
  Java interfaces.

## 0.11.0

- **Breaking Change** Removed `Jni.accessors`.
- Made most `Jni.env` methods into leaf functions to speed up their execution.
- Removed the dependency on `kotlin_gradle_plugin`.

## 0.10.1

- Fixed an issue with `JObject.castTo` where the type checking could fail in
  debug mode.
- Used `package:dart_flutter_team_lints`.

## 0.9.3

- Added lifetime event handling for the thread-local JNI env. Now
  `jvm.DetachNativeThread` is called when the thread detaches as recommended
  [here](https://developer.android.com/training/articles/perf-jni#threads).
- Removed `JValueChar.fromString` constructor.

## 0.9.2

- Bumped `minSdk` to 21.

## 0.9.1

- Fixed compilation on macOS for consumers that don't use JNI on macOS (which is
  still not supported) ([#1122](https://github.com/dart-lang/native/pull/1122)).

## 0.9.0

- **Breaking Change**
  ([#1004](https://github.com/dart-lang/native/issues/1004)): Changed the return
  type `operator []` of `JArray<jchar>` to `int` instead of `String`. Similarly,
  change the argument type of `operator []=` to accept `int`.
- Added `getRange` method to `JArray` of primitive types that returns a
  `TypedData` list depending on the kind of the array.
- Improved the performance of `JArray`'s `setRange` and `operator []=`.

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
- Use `package:dart_flutter_team_lints`.

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

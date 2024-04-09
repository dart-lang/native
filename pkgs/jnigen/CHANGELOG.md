## 0.8.1-wip

- Expand constraint on `package:cli_config` to allow `^0.2.0`.
- Ignore `use_super_parameters` lint in generated files.

## 0.8.0

- **Breaking Change** ([#981](https://github.com/dart-lang/native/issues/981)):
  - `fromRef` is now `fromReference`, and it gets a `JReference` instead of a
    `Pointer<Void>`.
  - Check out the internal changes to `JObject` in
    [`package:jni`'s changelog](https://github.com/dart-lang/native/blob/main/pkgs/jni/CHANGELOG.md#080-wip).
- **Breaking Change**: The generated impl class for interfaces is now an
  `interface`.
- **Breaking Change** ([#792](https://github.com/dart-lang/native/issues/792)]):
  `static final String` fields get converted to `JString` getters instead of
  `static const String` fields in Dart.
- Fixed a bug where a package would either be searched from sources or classes
  but not both.
- Fixed a bug where `<clinit>` (class initialization method) which is not
  necessary to be exposed was generated.

## 0.7.0

- **Breaking Change** ([#563](https://github.com/dart-lang/native/issues/563)):
  Added `JBuffer` and `JByteBuffer` classes as default classes for
  `java.nio.Buffer` and `java.nio.ByteBuffer` respectively.
- **Breaking Change**: Made the type classes `final`.
- Added `ignore_for_file: lines_longer_than_80_chars` to the generated file
  preamble.
- Added an explicit cast in generated `<Interface>.implement` code to allow
  `dart analyze` to pass when `strict-casts` is set.

## 0.6.0

- **Breaking Change** ([#707](https://github.com/dart-lang/native/issues/707)):
  Renamed `delete*` to `release*`.
- **Breaking Change** ([#585](https://github.com/dart-lang/native/issues/585)):
  Renamed constructors from `ctor1`, `ctor2`, ... to `new1`, `new2`, ...
- **Breaking Change**: Specifying a class always pulls in nested classes by
  default. If a nested class is specified in config, it will be an error.
- **Breaking Change**: Removed `suspend_fun_to_async` flag from the config. It's
  now happening by default since we read the Kotlin's metadata and reliably
  identify the `suspend fun`s.
- Fixed a bug where the nested classes would be generated incorrectly depending
  on the backend used for generation.
- Fixed a bug where ASM backend would produce the incorrect parent for
  multi-level nested classes.
- Fixed a bug where the backends would produce different descriptors for the
  same method.
- Added `enable_experiment` option to config.
- Created an experiment called `interface_implementation` which creates a
  `.implement` method for interfaces, so you can implement them using Dart.
- Save all `jnigen` logs to a file in `.dart_tool/jnigen/logs/`. This is useful
  for debugging.

## 0.5.0

- **Breaking Change** ([#746](https://github.com/dart-lang/native/issues/746)):
  Removed support for `importMap` in favor of the newly added interop mechanism
  with importing yaml files.
- **Breaking Change** ([#746](https://github.com/dart-lang/native/issues/746)):
  `java.util.Set`, `java.util.Map`, `java.util.List`, `java.util.Iterator` and
  the boxed types like `java.lang.Integer`, `java.lang.Double`, ... will be
  generated as their corresponding classes in `package:jni`.
- Strings now use UTF16.

## 0.4.0

- **Breaking Change** ([#705](https://github.com/dart-lang/native/issues/705)):
  Type arguments are now named instead of positional.
- Type parameters can now be inferred when possible.
- Fixed a bug where passing a `long` argument truncated it to `int` in pure dart
  bindings.
- Removed array extensions from the generated code.
- Added the ability to use source dependencies from Gradle.
- Fixed an issue with the field setter.
- Fixed an issue where exceptions were not properly thrown in pure Dart
  bindings.

## 0.3.0

- Added the option to convert Kotlin `suspend fun` to Dart async methods. Add
  `suspend_fun_to_async: true` to `jnigen.yaml`.

## 0.2.0

- Support generating bindings for generics.

## 0.1.1

- Windows support for running tests and examples on development machines.

## 0.1.0

- Initial version: Basic bindings generation, maven and android utilities

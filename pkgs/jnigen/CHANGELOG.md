## 0.14.1-wip

- Added support for generating matching Kotlin operators as Dart operators.
- Include the methods of the superinterfaces of a class or interface in the
  bindings.
- Fix a bug where Kotlin suspendable functions that returned the result without
  ever suspending would timeout in Dart.

## 0.14.0

- Fixed a bug where the source parser would not have all of the type paremeters
  of the types.

## 0.13.1

- Fixed a bug where Kotlin wildcards would crash the code generation.
- Support nullability annotations that are on Java elements like methods and
  fields instead of directly on the return type or field type.
- Fixed a bug where enum values were generated as nullable.
- Fixed a bug where type arguments could be nullable when the top type of their
  paramater was non-nullable.

## 0.13.0

- **Breaking Change**([#1516](https://github.com/dart-lang/native/issues/1516)):
  Inner classes are now generated as `OuterClass$InnerClass`.
- **Breaking Change**([#1644](https://github.com/dart-lang/native/issues/1644)):
  Generate null-safe Dart bindings for Java and Kotlin.
- Fixed a potential name collision when generating in multi-file mode.
- Added the ability to add user-defined visitors to config. Currently only
  capable of excluding classes, methods, and fields.
- Add dependency override for `package:jni` instead of the path dependency.

## 0.12.2

- Now excludes invalid identifiers by default.
- Fixed a bug where if multiple jars have classes within the same package, only
  one of them gets generated.
- Fixed a bug where it would be possible for a type class inference to fail.
- Improve the diagnostics when gradle fails when `bin/jnigen` is run.

## 0.12.1

- Support implementing generic functions in interfaces.

## 0.12.0

- **Breaking Change**([#1530](https://github.com/dart-lang/native/pull/1530)):
  Changed the renaming strategy for method overloadings. Instead of adding a
  numeric suffix, we add a dollar sign (`$`) and then the numeric suffix. This
  is done to avoid name collision between methods that originally end with
  numeric suffices and the renamed overloads. Similarly names that are Dart
  keywords get a dollar sign suffix now. For more information, check out the
  [documentation](https://github.com/dart-lang/native/tree/main/pkgs/jnigen/docs/java_differences.md#method-overloading).
- **Breaking Change**: Each single dollar sign is replaced with two dollar signs
  in the identifier names.
- **Breaking Change**: Removed the `Impl` suffix from the generated
  implemenation classes. So the implementation class for an interface named
  `Foo` is now simply called `$Foo` instead of `$FooImpl`.
- **Breaking Change**: Renamed and made the typeclasses internal.
- **Breaking Change**: Relaxed the renaming rules to allow for more identifiers
  to remain unchanged.
- Added `JImplementer` which enables building an object that implements multiple
  Java interfaces. Each interface now has a static `implementIn` method that
  takes a `JImplementer` and the implementation object.
- Added the ability to implement void-returning interface methods as listeners.
- Generating identifiers that start with an underscore (`_`) and making them
  public by prepending a dollar sign.
- Fixed an issue where inheriting a generic class could generate incorrect code.
- No longer generating constructors for abstract classes.
- No longer generating `protected` elements.
- Fixed an issue where synthetic methods caused code generation to fail.

## 0.11.0

- No changes. Keep major version in sync with `package:jni`.

## 0.10.1

- Added backticks to code references in doc comments.

## 0.10.0

- Added support for Kotlin's top-level functions and fields.
- Used `package:dart_flutter_team_lints`.

## 0.9.3

- Fixed a bug where wrong argument types were generated for varargs.
- Fixed the macOS arm64 varargs issue caused by the previous release.
- Support throwing Java exceptions from Dart code.
  ([#1209](https://github.com/dart-lang/native/issues/1209))

## 0.9.2

- Fixed a bug where wrong argument types were generated for 32-bit
  architectures. This temporarily breaks generated bindings for macOS arm64,
  until the fix is cherry-picked on Dart stable.

## 0.9.1

- Fixed a bug in summarizer where standard output would use the default encoding
  of the operating system and therefore breaking the UTF-8 decoding for some
  locales.

## 0.9.0

- **Breaking Change** ([#660](https://github.com/dart-lang/native/issues/660)):
  Removed C-based bindings. Now all bindings are Dart-only.
- Expanded constraint on `package:cli_config` to allow `^0.2.0`.
- Ignored `use_super_parameters` lint in generated files.
- Fixed a bug in summarizer and improved the display of errors.

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

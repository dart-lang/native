## 0.5.0-dev.0
* No JNIGen changes (yet), but keeping version in lockstep with `package:jni`.

## 0.4.0
* **Breaking Change** ([#145](https://github.com/dart-lang/jnigen/issues/145)): Type arguments are now named instead of positional.
* Type parameters can now be inferred when possible.
* Fixed a bug where passing a `long` argument truncated it to `int` in pure dart bindings.
* Removed array extensions from the generated code.
* Added the ability to use source dependencies from Gradle.
* Fixed an issue with the field setter.
* Fixed an issue where exceptions were not properly thrown in pure Dart bindings.

## 0.3.0
* Added the option to convert Kotlin `suspend fun` to Dart async methods. Add `suspend_fun_to_async: true` to `jnigen.yaml`.

## 0.2.0
* Support generating bindings for generics.

## 0.1.1
* Windows support for running tests and examples on development machines.

## 0.1.0
* Initial version: Basic bindings generation, maven and android utilities

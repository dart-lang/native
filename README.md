[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)

## Overview

This repository is home to Dart packages related to FFI and native assets
building and bundling.

## Packages

| Package | Description | Issues | Version |
| --- | --- | --- | --- |
| [code_assets](pkgs/code_assets/) | This package contains the Dart API for code assets in `hook/build.dart` and `hook/link.dart`.  | [![issues](https://img.shields.io/badge/package:code__assets-4774bc)][code_assets_issues] | [![pub package](https://img.shields.io/pub/v/code_assets.svg)](https://pub.dev/packages/code_assets) |
| [data_assets](pkgs/data_assets/) | This package contains the Dart API for data assets in `hook/build.dart` and `hook/link.dart`.  | [![issues](https://img.shields.io/badge/package:data__assets-4774bc)][data_assets_issues] | [![pub package](https://img.shields.io/pub/v/data_assets.svg)](https://pub.dev/packages/data_assets) |
| [ffi](pkgs/ffi/) | Utilities for working with Foreign Function Interface (FFI) code. | [![issues](https://img.shields.io/badge/package:ffi-4774bc)][ffi_issues] | [![pub package](https://img.shields.io/pub/v/ffi.svg)](https://pub.dev/packages/ffi) |
| [ffigen](pkgs/ffigen/) | Generator for FFI bindings, using LibClang to parse C, Objective-C, and Swift files. | [![issues](https://img.shields.io/badge/package:ffigen-4774bc)][ffigen_issues] | [![pub package](https://img.shields.io/pub/v/ffigen.svg)](https://pub.dev/packages/ffigen) |
| [hooks](pkgs/hooks/) | This package contains the API for `hook/build.dart` and `hook/link.dart`. | [![issues](https://img.shields.io/badge/package:hooks-4774bc)][hooks_issues] | [![pub package](https://img.shields.io/pub/v/hooks.svg)](https://pub.dev/packages/hooks) |
| [hooks_runner](pkgs/hooks_runner/) | This package is the backend that invokes `hook/build.dart` and `hook/link.dart` from Dart and Flutter. | [![issues](https://img.shields.io/badge/package:hooks__runner-4774bc)][hooks_runner_issues] | [![pub package](https://img.shields.io/pub/v/hooks_runner.svg)](https://pub.dev/packages/hooks_runner) |
| [jni](pkgs/jni/) | A library to access JNI from Dart and Flutter that acts as a support library for package:jnigen. | [![issues](https://img.shields.io/badge/package:jni-4774bc)][jni_issues] | [![pub package](https://img.shields.io/pub/v/jni.svg)](https://pub.dev/packages/jni) |
| [jnigen](pkgs/jnigen/) | A Dart bindings generator for Java and Kotlin that uses JNI under the hood to interop with Java virtual machine. | [![issues](https://img.shields.io/badge/package:jnigen-4774bc)][jnigen_issues] | [![pub package](https://img.shields.io/pub/v/jnigen.svg)](https://pub.dev/packages/jnigen) |
| [native_doc_dartifier](pkgs/native_doc_dartifier/) | A library that converts code snippets from other languages into Dart. | [![issues](https://img.shields.io/badge/package:native__doc__dartifier-4774bc)](native_doc_dartifier_issues) | [![pub package](https://img.shields.io/pub/v/native_doc_dartifier.svg)](https://pub.dev/packages/native_doc_dartifier) |
| [native_toolchain_c](pkgs/native_toolchain_c/) | A library to invoke the native C compiler installed on the host machine. | [![issues](https://img.shields.io/badge/package:native__toolchain__c-4774bc)][native_toolchain_c_issues] | [![pub package](https://img.shields.io/pub/v/native_toolchain_c.svg)](https://pub.dev/packages/native_toolchain_c) |
| [objective_c](pkgs/objective_c/) | A library to access Objective C from Flutter that acts as a support library for package:ffigen. | [![issues](https://img.shields.io/badge/package:objective__c-4774bc)][objective_c_issues] | [![pub package](https://img.shields.io/pub/v/objective_c.svg)](https://pub.dev/packages/objective_c) |
| [swift2objc](pkgs/swift2objc/) | A tool for generating bindings that allow interop between Dart and Swift code. | [![issues](https://img.shields.io/badge/package:swift2objc-4774bc)][swift2objc_issues] | [![pub package](https://img.shields.io/pub/v/swift2objc.svg)](https://pub.dev/packages/swift2objc) |
| [swiftgen](pkgs/swiftgen/) | A tool for generating bindings that allow interop between Dart and Swift code. | [![issues](https://img.shields.io/badge/package:swiftgen-4774bc)][swiftgen_issues] | [![pub package](https://img.shields.io/pub/v/swiftgen.svg)](https://pub.dev/packages/swiftgen) |

[code_assets_issues]: https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Acode_assets
[data_assets_issues]: https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Adata_assets
[ffi_issues]: https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Affi
[ffigen_issues]: https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Affigen
[hooks_issues]: https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Ahooks
[hooks_runner_issues]: https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Ahooks_runner
[jni_issues]: https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Ajni
[jnigen_issues]: https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Ajnigen
[native_toolchain_c_issues]: https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Anative_toolchain_c
[objective_c_issues]: https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Aobjective_c
[swift2objc_issues]: https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Aswift2objc
[swiftgen_issues]: https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Aswiftgen

## External packages

Packages not on this repo but also related to FFI and native assets. ❤️

| Package | Description | Version |
| --- | --- | --- |
| [native_toolchain_cmake](https://github.com/rainyl/native_toolchain_cmake) | A library to invoke CMake for Dart Native Assets. | [![pub package](https://img.shields.io/pub/v/native_toolchain_cmake.svg)](https://pub.dev/packages/native_toolchain_cmake) |
| [native_toolchain_go](https://github.com/csnewman/flutter-go-bridge/tree/master/native_toolchain_go) | A library to invoke the native Go compiler installed on the host machine. | [![pub package](https://img.shields.io/pub/v/native_toolchain_go.svg)](https://pub.dev/packages/native_toolchain_go) |
| [native_toolchain_rust](https://github.com/irondash/native_toolchain_rust) | A library to invoke the native Rust compiler installed on the host machine. | [![pub package](https://img.shields.io/pub/v/native_toolchain_rust.svg)](https://pub.dev/packages/native_toolchain_rust) |

## Publishing automation

For information about our publishing automation and release process, see
https://github.com/dart-lang/ecosystem/wiki/Publishing-automation.

For additional information about contributing, see our
[contributing](CONTRIBUTING.md) page.

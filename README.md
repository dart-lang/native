[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)

## Overview

This repository is home to Dart packages related to FFI and native assets
building and bundling.

## Packages

| Package | Description | Issues | Version |
| --- | --- | --- | --- |
| [ffi](pkgs/ffi/) | Utilities for working with Foreign Function Interface (FFI) code. | [![package issues](https://img.shields.io/badge/package:ffi-4774bc)](https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Affi) | [![pub package](https://img.shields.io/pub/v/ffi.svg)](https://pub.dev/packages/ffi) |
| [ffigen](pkgs/ffigen/) | Generator for FFI bindings, using LibClang to parse C, Objective-C, and Swift files. | [![package issues](https://img.shields.io/badge/package:ffigen-4774bc)](https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Affigen) | [![pub package](https://img.shields.io/pub/v/ffigen.svg)](https://pub.dev/packages/ffigen) |
| [jni](pkgs/jni/) | A library to access JNI from Dart and Flutter that acts as a support library for package:jnigen. | [![package issues](https://img.shields.io/badge/package:jni-4774bc)](https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Ajni) | [![pub package](https://img.shields.io/pub/v/jni.svg)](https://pub.dev/packages/jni) |
| [jnigen](pkgs/jnigen/) | A Dart bindings generator for Java and Kotlin that uses JNI under the hood to interop with Java virtual machine. | [![package issues](https://img.shields.io/badge/package:jnigen-4774bc)](https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Ajnigen) | [![pub package](https://img.shields.io/pub/v/jnigen.svg)](https://pub.dev/packages/jnigen) |
| [native_assets_builder](pkgs/native_assets_builder/) | This package is the backend that invokes build hooks. | [![package issues](https://img.shields.io/badge/package:native__assets__builder-4774bc)](https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Anative_assets_builder) |  |
| [native_assets_cli](pkgs/native_assets_cli/) | A library that contains the argument and file formats for implementing a native assets CLI. | [![package issues](https://img.shields.io/badge/package:native__assets__cli-4774bc)](https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Anative_assets_cli) |  |
| [native_toolchain_c](pkgs/native_toolchain_c/) | A library to invoke the native C compiler installed on the host machine. | [![package issues](https://img.shields.io/badge/package:native__toolchain__c-4774bc)](https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Anative_toolchain_c) |  |
| [objective_c](pkgs/objective_c/) | A library to access Objective C from Flutter that acts as a support library for package:ffigen. | [![package issues](https://img.shields.io/badge/package:objective__c-4774bc)](https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Aobjective_c) | [![pub package](https://img.shields.io/pub/v/objective_c.svg)](https://pub.dev/packages/objective_c) |
| [swift2objc](pkgs/swift2objc/) | A tool for generating bindings that allow interop between Dart and Swift code. | [![package issues](https://img.shields.io/badge/package:swift2objc-4774bc)](https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Aswift2objc) | [![pub package](https://img.shields.io/pub/v/swift2objc.svg)](https://pub.dev/packages/swift2objc) |
| [swiftgen](pkgs/swiftgen/) | A tool for generating bindings that allow interop between Dart and Swift code. | [![package issues](https://img.shields.io/badge/package:swiftgen-4774bc)](https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Aswiftgen) | [![pub package](https://img.shields.io/pub/v/swiftgen.svg)](https://pub.dev/packages/swiftgen) |

## External packages

Packages not on this repo but also related to FFI and native assets. ❤️

| Package | Description | Version |
| --- | --- | --- |
| [native_toolchain_go](https://github.com/csnewman/flutter-go-bridge/tree/master/native_toolchain_go) | A library to invoke the native Go compiler installed on the host machine. | [![pub package](https://img.shields.io/pub/v/native_toolchain_go.svg)](https://pub.dev/packages/native_toolchain_go) |
| [native_toolchain_rust](https://github.com/irondash/native_toolchain_rust) | A library to invoke the native Rust compiler installed on the host machine. | [![pub package](https://img.shields.io/pub/v/native_toolchain_rust.svg)](https://pub.dev/packages/native_toolchain_rust) |

## Publishing automation

For information about our publishing automation and release process, see
https://github.com/dart-lang/ecosystem/wiki/Publishing-automation.

For additional information about contributing, see our
[contributing](CONTRIBUTING.md) page.

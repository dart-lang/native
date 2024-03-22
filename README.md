[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)

## Overview

This repository is home to Dart packages related to FFI and native assets
building and bundling.

## Packages

| Package | Description | Version |
| --- | --- | --- |
| [ffi](pkgs/ffi/) | Utilities for working with Foreign Function Interface (FFI) code. | [![pub package](https://img.shields.io/pub/v/ffi.svg)](https://pub.dev/packages/ffi) |
| [ffigen](pkgs/ffigen/) | Generator for FFI bindings, using LibClang to parse C, Objective-C, and Swift files. | [![pub package](https://img.shields.io/pub/v/ffigen.svg)](https://pub.dev/packages/ffigen) |
| [jni](pkgs/jni/) | A library to access JNI from Dart and Flutter that acts as a support library for `package:jnigen`. | [![pub package](https://img.shields.io/pub/v/jni.svg)](https://pub.dev/packages/jni) |
| [jnigen](pkgs/jnigen/) | A Dart bindings generator for Java and Kotlin that uses JNI under the hood to interop with Java virtual machine. | [![pub package](https://img.shields.io/pub/v/jnigen.svg)](https://pub.dev/packages/jnigen) |
| [native_assets_builder](pkgs/native_assets_builder/) | This package is the backend that invokes build hooks. | [![pub package](https://img.shields.io/pub/v/native_assets_builder.svg)](https://pub.dev/packages/native_assets_builder) |
| [native_assets_cli](pkgs/native_assets_cli/) | A library that contains the argument and file formats for implementing a native assets CLI. | [![pub package](https://img.shields.io/pub/v/native_assets_cli.svg)](https://pub.dev/packages/native_assets_cli) |
| [native_toolchain_c](pkgs/native_toolchain_c/) | A library to invoke the native C compiler installed on the host machine. | [![pub package](https://img.shields.io/pub/v/native_toolchain_c.svg)](https://pub.dev/packages/native_toolchain_c) |

## Publishing automation

For information about our publishing automation and release process, see
https://github.com/dart-lang/ecosystem/wiki/Publishing-automation.

For additional information about contributing, see our
[contributing](CONTRIBUTING.md) page.

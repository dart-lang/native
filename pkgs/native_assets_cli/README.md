[![package:native_assets_cli](https://github.com/dart-lang/native/actions/workflows/dart.yaml/badge.svg)](https://github.com/dart-lang/native/actions/workflows/dart.yaml)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)
[![pub package](https://img.shields.io/pub/v/native_assets_cli.svg)](https://pub.dev/packages/native_assets_cli)
[![package publisher](https://img.shields.io/pub/publisher/native_assets_cli.svg)](https://pub.dev/packages/native_assets_cli/publisher)

This library contains the CLI specification and a default implementation
for bundling native code with Dart packages.

## Status

The native assets feature is experimental, and will likely undergo breaking
changes while the feature is in development.

## Example

A typical layout of a package with native code is:

* `lib/` contains Dart code which uses [`dart:ffi`] and [`package:ffigen`]
  to call into native code.
* `src/` contains C/C++/Rust code which is invoked through `dart:ffi`.
* `build.dart` implements the CLI that communicates which native assets
  to build/bundle with the Dart/Flutter SDK. This file uses the
  protocol specified in this package.

An example can be found in [example/](example/).

## Usage

Using the native assets feature requires passing
`--enable-experiment=native-assets` in Dart on a dev build.

The native assets feature is not yet available in Flutter.

## Development

The development of the feature can be tracked in [dart-lang#50565],
[flutter#129757], and in the issue tracker on this repository.

[`dart:ffi`]: https://api.dart.dev/stable/dart-ffi/dart-ffi-library.html
[`package:ffigen`]: https://pub.dev/packages/ffigen
[dart-lang#50565]: https://github.com/dart-lang/sdk/issues/50565
[flutter#129757]: https://github.com/flutter/flutter/issues/129757

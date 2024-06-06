[![package:native_assets_cli](https://github.com/dart-lang/native/actions/workflows/native.yaml/badge.svg)](https://github.com/dart-lang/native/actions/workflows/native.yaml)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)
[![pub package](https://img.shields.io/pub/v/native_assets_cli.svg)](https://pub.dev/packages/native_assets_cli)
[![package publisher](https://img.shields.io/pub/publisher/native_assets_cli.svg)](https://pub.dev/packages/native_assets_cli/publisher)

This library contains the CLI specification and a default implementation
for bundling native code with Dart packages.

## Status: Experimental

**NOTE**: This package is currently experimental and published under the
[labs.dart.dev](https://dart.dev/dart-team-packages) pub publisher in order to
solicit feedback. 

For packages in the labs.dart.dev publisher we generally plan to either graduate
the package into a supported publisher (dart.dev, tools.dart.dev) after a period
of feedback and iteration, or discontinue the package. These packages have a
much higher expected rate of API and breaking changes.

Your feedback is valuable and will help us evolve this package. 
For bugs, please file an issue in the 
[bug tracker](https://github.com/dart-lang/native/issues).
For general feedback and suggestions for the native assets feature in Dart and
Flutter, please comment in [dart-lang#50565] or [flutter#129757].

## Example

A typical layout of a package with native code is:

* `lib/` contains Dart code which uses [`dart:ffi`] and [`package:ffigen`]
  to call into native code.
* `src/` contains C/C++/Rust code which is invoked through `dart:ffi`.
* `hook/build.dart` implements the CLI that communicates which native assets
  to build/bundle with the Dart/Flutter SDK. This file uses the
  protocol specified in this package.

Example can be found in [example/build/](example/build/).

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

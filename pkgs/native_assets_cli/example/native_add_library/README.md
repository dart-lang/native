An example library containing native code that should be bundled with Dart and
Flutter applications.

## Usage

Run tests with `dart --enable-experiment=native-assets test`.

## Code organization

A typical layout of a package with native code is:

* `lib/` contains Dart code which uses [`dart:ffi`] and [`package:ffigen`]
  to call into native code.
* `src/` contains C code which is built and then invoked through `dart:ffi`.
* `build.dart` implements the CLI that communicates which native assets
  to build/bundle with the Dart/Flutter SDK.

[![package:code_assets](https://github.com/dart-lang/native/actions/workflows/native.yaml/badge.svg)](https://github.com/dart-lang/native/actions/workflows/native.yaml)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)
[![pub package](https://img.shields.io/pub/v/code_assets.svg)](https://pub.dev/packages/code_assets)
[![package publisher](https://img.shields.io/pub/publisher/code_assets.svg)](https://pub.dev/packages/code_assets/publisher)

A library to use in build hooks (`hook/build.dart`) for building and bundling
code assets.

Code assets can be added in a build hook as follows:

```dart
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final assetPath = input.outputDirectory.resolve('...');

    output.assets.code.add(
      CodeAsset(
        package: packageName,
        name: '...',
        linkMode: DynamicLoadingBundled(),
        file: assetPath,
      ),
    );
  });
}
```

For more documentation of hooks, refer to the API docs of
[`package:hooks`](https://pub.dev/packages/hooks).

When compiling C, C++ or Objective-C code from source, consider using
[`package:native_toolchain_c`](https://pub.dev/packages/native_toolchain_c).

## Status: In Preview

**NOTE**: This package is currently in preview and published under the
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

[dart-lang#50565]: https://github.com/dart-lang/sdk/issues/50565
[flutter#129757]: https://github.com/flutter/flutter/issues/129757


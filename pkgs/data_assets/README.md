[![package:data_assets](https://github.com/dart-lang/native/actions/workflows/native.yaml/badge.svg)](https://github.com/dart-lang/native/actions/workflows/native.yaml)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)
[![pub package](https://img.shields.io/pub/v/data_assets.svg)](https://pub.dev/packages/data_assets)
[![package publisher](https://img.shields.io/pub/publisher/data_assets.svg)](https://pub.dev/packages/data_assets/publisher)

A library to use in build hooks (`hook/build.dart`) for building and bundling
data assets.

Data assets can be added in a build hook as follows:

```dart
import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
///
void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final assetPath = input.outputDirectory.resolve('...');

    output.assets.data.add(
      DataAsset(
        package: packageName,
        name: '...',
        file: assetPath,
      ),
    );
  });
}
```

For more documentation of hooks, refer to the API docs of
[`package:hooks`](https://pub.dev/packages/hooks).

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


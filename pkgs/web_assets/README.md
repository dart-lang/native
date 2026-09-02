[![package:web_assets](https://github.com/dart-lang/native/actions/workflows/native.yaml/badge.svg)](https://github.com/dart-lang/native/actions/workflows/native.yaml)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)
[![pub package](https://img.shields.io/pub/v/web_assets.svg)](https://pub.dev/packages/web_assets)
[![package publisher](https://img.shields.io/pub/publisher/web_assets.svg)](https://pub.dev/packages/data_assets/publisher)

A library to use in build (`hook/build.dart`) and link (`hook/link.dart`) hooks
for building and bundling assets for Dart web applications.

When a Dart application is built for the web, web assets are included as part
of the generated bundle and their URI can be resolved at runtime. Essentially,
these assets are files in a `web/` directory that can be contributed by
packages.

Data assets can be added in a build hook as follows:

<!-- file://./example/api/web_assets_snippet.dart -->
```dart
import 'package:hooks/hooks.dart';
import 'package:web_assets/web_assets.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildWebAssets) {
      final packageName = input.packageName;
      final assetPathInPackage = input.packageRoot.resolve('...');
      final assetPathDownload = input.outputDirectoryShared.resolve('...');

      output.assets.web.add(
        WebAsset(
          package: packageName,
          name: '...',
          file: assetPathInPackage,
        ),
      );
    }
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


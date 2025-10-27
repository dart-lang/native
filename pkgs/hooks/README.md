[![dart](https://github.com/dart-lang/native/actions/workflows/native.yaml/badge.svg)](https://github.com/dart-lang/native/actions/workflows/native.yaml)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)
[![pub package](https://img.shields.io/pub/v/hooks.svg)](https://pub.dev/packages/hooks)
[![package publisher](https://img.shields.io/pub/publisher/hooks.svg)](https://pub.dev/packages/hooks/publisher)

This package provides the API for hooks in Dart. Hooks are Dart
scripts placed in the `hook/` directory of a Dart package, designed to automate
tasks for a Dart package.

Currently, the main supported hook is the build hook (`hook/build.dart`). The
build hook is executed during a Dart build and enables you to bundle assets with
a Dart package.

The main supported asset type is a code asset, code written in other languages
that are compiled into machine code. You can use a build hook to do things such
as compile or download code assets, and then call these assets from the Dart
code of a package. The
[`CodeAsset`](https://pub.dev/documentation/code_assets/latest/code_assets/CodeAsset-class.html)
API is an extension to this package and is available in
[`package:code_assets`](https://pub.dev/packages/code_assets).

When compiling C, C++ or Objective-C code from source, consider using
[`package:native_toolchain_c`](https://pub.dev/packages/native_toolchain_c):

<!-- file://./../code_assets/example/sqlite/hook/build.dart -->
```dart
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      final builder = CBuilder.library(
        name: 'sqlite3',
        assetName: 'src/third_party/sqlite3.g.dart',
        sources: ['third_party/sqlite/sqlite3.c'],
        defines: {
          if (input.config.code.targetOS == OS.windows)
            // Ensure symbols are exported in dll.
            'SQLITE_API': '__declspec(dllexport)',
        },
      );
      await builder.run(input: input, output: output);
    }
  });
}
```

See the full example in [package:code_assets
example/sqlite/](../code_assets/example/sqlite/).

When bundling precompiled dynamic libraries, use `package:code_assets` directly:

<!-- file://./../code_assets/example/api/code_assets_snippet.dart -->
```dart
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      final packageName = input.packageName;
      final assetPath = input.packageRoot.resolve('...');
      final assetPathDownloaded = input.outputDirectoryShared.resolve('...');

      output.assets.code.add(
        CodeAsset(
          package: packageName,
          name: '...',
          linkMode: DynamicLoadingBundled(),
          file: assetPath,
        ),
      );
    }
  });
}
```

For more information see [dart.dev/tools/hooks](https://dart.dev/tools/hooks).

## Documentation

For detailed documentation on debugging and the configuration schema, see the
[documentation](./doc/README.md).

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

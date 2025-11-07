[![package:code_assets](https://github.com/dart-lang/native/actions/workflows/native.yaml/badge.svg)](https://github.com/dart-lang/native/actions/workflows/native.yaml)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)
[![pub package](https://img.shields.io/pub/v/code_assets.svg)](https://pub.dev/packages/code_assets)
[![package publisher](https://img.shields.io/pub/publisher/code_assets.svg)](https://pub.dev/packages/code_assets/publisher)

This package provides the API for code assets to be used with
[`package:hooks`](https://pub.dev/packages/hooks).

A code asset is an asset containing executable code which respects the native
application binary interface (ABI). These assets are bundled with a Dart or
Flutter application. They can be produced by compiling C, C++, Objective-C,
Rust, or Go code for example.

This package is used in a build hook (`hook/build.dart`) to inform the Dart
and Flutter SDKs about the code assets that need to be bundled with an
application.

Code assets can be added in a build hook as follows:

<!-- file://./example/api/code_assets_snippet.dart -->
```dart
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      final packageName = input.packageName;
      final assetPathInPackage = input.packageRoot.resolve('...');
      final assetPathDownload = input.outputDirectoryShared.resolve('...');

      output.assets.code.add(
        CodeAsset(
          package: packageName,
          name: '...',
          linkMode: DynamicLoadingBundled(),
          file: assetPathInPackage,
        ),
      );
    }
  });
}
```

When compiling C, C++ or Objective-C code from source, consider using
[`package:native_toolchain_c`](https://pub.dev/packages/native_toolchain_c):

<!-- file://./example/sqlite/hook/build.dart -->
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

See the full example in [example/sqlite/](example/sqlite/).

When interfacing with system libraryies, the API in this package is enough:

<!-- file://./example/host_name/hook/build.dart -->
```dart
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      switch (input.config.code.targetOS) {
        case OS.android || OS.iOS || OS.linux || OS.macOS:
          output.assets.code.add(
            CodeAsset(
              package: 'host_name',
              name: 'src/third_party/unix.dart',
              linkMode: LookupInProcess(),
            ),
          );
        case OS.windows:
          output.assets.code.add(
            CodeAsset(
              package: 'host_name',
              name: 'src/third_party/windows.dart',
              linkMode: DynamicLoadingSystem(Uri.file('ws2_32.dll')),
            ),
          );
        case final os:
          throw UnsupportedError('Unsupported OS: ${os.name}.');
      }
    }
  });
}
```

See the full example in [example/host_name/](example/host_name/).

For more information see [dart.dev/tools/hooks](https://dart.dev/tools/hooks).


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

<!-- file://./../code_assets/example/sqlite_no_link/hook/build.dart -->
```dart
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

final builder = CBuilder.library(
  name: 'sqlite3',
  assetName: 'src/third_party/sqlite3.g.dart',
  sources: ['third_party/sqlite/sqlite3.c'],
);

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      await builder.run(
        input: input,
        output: output,
        defines: {
          if (input.config.code.targetOS == OS.windows)
            // Ensure symbols are exported in dll.
            'SQLITE_API': '__declspec(dllexport)',
        },
      );
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

For more information see [dart.dev/tools/hooks](https://dart.dev/tools/hooks).

## User-defines

Because build hooks execute in a semi-hermetic environment where most environment variables are stripped for reproducibility and caching purposes, you should use **user-defines** to pass custom configurations, flags, or paths to your hooks from `pubspec.yaml`.

### 1. Define in `pubspec.yaml`
In your package (or workspace root `pubspec.yaml` if using workspaces), add the `hooks.user_defines` section:

```yaml
hooks:
  user_defines:
    my_package_name:
      enable_debug_logging: true
      custom_asset: assets/data.json
```

> [!IMPORTANT]  
> **Workspace Scope:** If a project is set up as a **pub workspace**, the `hooks.user_defines` configuration block must be placed in the **workspace root** `pubspec.yaml` file. Defines inside member package `pubspec.yaml` files are ignored when workspace resolution is active.

### 2. Read in `hook/build.dart` or `hook/link.dart`
Access the values using `input.userDefines`:

<!-- file://./example/api/config_snippet_6.dart -->
```dart
import 'dart:io';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    // Access raw user-defines value
    final debugLogging = input.userDefines['enable_debug_logging'];
    if (debugLogging is! bool?) {
      throw const FormatException(
        'hooks.user_defines.my_package.enable_debug_logging must be a '
        'boolean (or omitted)',
      );
    }
    if (debugLogging == true) {
      print('Debug logging is enabled.');
    }

    // Resolve relative path against pubspec.yaml base path
    final customAssetUri = input.userDefines.path('custom_asset');
    if (customAssetUri != null) {
      final file = File.fromUri(customAssetUri);
      output.dependencies.add(file.uri); // Declare cache dependency
      // Use the file...
    }
  });
}
```

## Documentation

For detailed documentation on debugging and the configuration schema, see the
[documentation](./doc/README.md).


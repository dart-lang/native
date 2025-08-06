// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @docImport 'src/code_assets/code_asset.dart';
/// @docImport 'src/code_assets/config.dart';

/// Code asset support for hook authors.
///
/// Code assets can be added in a build hook as follows:
///
/// ```dart
/// import 'package:code_assets/code_assets.dart';
/// import 'package:hooks/hooks.dart';
///
/// void main(List<String> args) async {
///   await build(args, (input, output) async {
///     final packageName = input.packageName;
///     final assetPath = input.outputDirectory.resolve('...');
///
///     output.assets.code.add(
///       CodeAsset(
///         package: packageName,
///         name: '...',
///         linkMode: DynamicLoadingBundled(),
///         file: assetPath,
///       ),
///     );
///   });
/// }
/// ```
///
/// See [CodeAsset] and [BuildOutputCodeAssetBuilder.add] for more details.
///
/// For more documentation of hooks, refer to the API docs of
/// [`package:hooks`](https://pub.dev/packages/hooks).
///
/// When compiling C, C++ or Objective-C code from source, consider using
/// [`package:native_toolchain_c`](https://pub.dev/packages/native_toolchain_c).
library;

export 'src/code_assets/architecture.dart' show Architecture;
export 'src/code_assets/c_compiler_config.dart'
    show CCompilerConfig, DeveloperCommandPrompt, WindowsCCompilerConfig;
export 'src/code_assets/code_asset.dart'
    show CodeAsset, EncodedCodeAsset, OSLibraryNaming;
export 'src/code_assets/config.dart'
    show
        AndroidCodeConfig,
        BuildOutputAssetsBuilderCode,
        BuildOutputCodeAssetBuilder,
        BuildOutputCodeAssets,
        CodeConfig,
        HookConfigCodeConfig,
        IOSCodeConfig,
        LinkInputCodeAssets,
        LinkOutputAssetsBuilderCode,
        LinkOutputCodeAssetBuilder,
        LinkOutputCodeAssets,
        MacOSCodeConfig;
export 'src/code_assets/extension.dart';
export 'src/code_assets/ios_sdk.dart' show IOSSdk;
export 'src/code_assets/link_mode.dart'
    show
        DynamicLoadingBundled,
        DynamicLoadingSystem,
        LinkMode,
        LookupInExecutable,
        LookupInProcess,
        StaticLinking;
export 'src/code_assets/link_mode_preference.dart' show LinkModePreference;
export 'src/code_assets/os.dart' show OS;
export 'src/code_assets/testing.dart' show testCodeBuildHook;

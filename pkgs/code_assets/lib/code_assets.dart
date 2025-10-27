// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @docImport 'package:hooks/hooks.dart';
/// @docImport 'src/code_assets/code_asset.dart';
/// @docImport 'src/code_assets/config.dart';

/// This package provides the API for code assets to be used with
/// [`package:hooks`](https://pub.dev/packages/hooks).
///
/// A [CodeAsset] is an asset containing executable code which respects the
/// native application binary interface (ABI). These assets are bundled with a
/// Dart or Flutter application. They can be produced by compiling C, C++,
/// Objective-C, Rust, or Go code for example.
///
/// This package is used in a build hook (`hook/build.dart`) to inform the Dart
/// and Flutter SDKs about the code assets that need to be bundled with an
/// application.
///
/// A [CodeAsset] can be added to the [BuildOutputBuilder] in a build hook as
/// follows:
///
/// <!-- file://./../example/api/code_assets_snippet.dart -->
/// ```dart
/// import 'package:code_assets/code_assets.dart';
/// import 'package:hooks/hooks.dart';
///
/// void main(List<String> args) async {
///   await build(args, (input, output) async {
///     if (input.config.buildCodeAssets) {
///       final packageName = input.packageName;
///       final assetPath = input.packageRoot.resolve('...');
///       final assetPathDownloaded = input.outputDirectoryShared.resolve('...');
///
///       output.assets.code.add(
///         CodeAsset(
///           package: packageName,
///           name: '...',
///           linkMode: DynamicLoadingBundled(),
///           file: assetPath,
///         ),
///       );
///     }
///   });
/// }
/// ```
///
/// The [CodeConfig] nested in the [HookInput] gives access to configuration
/// specifically for compiling code assets. For example [CodeConfig.targetOS]
/// and [CodeConfig.targetArchitecture] give access to the target OS and
/// architecture that the code assets are compiled for:
///
/// <!-- file://./../example/api/code_config_snippet.dart -->
/// ```dart
/// import 'package:code_assets/code_assets.dart';
/// import 'package:hooks/hooks.dart';
///
/// void main(List<String> args) async {
///   await build(args, (input, output) async {
///     if (input.config.buildCodeAssets) {
///       final codeConfig = input.config.code;
///       final targetOS = codeConfig.targetOS;
///       final targetArchitecture = codeConfig.targetArchitecture;
///
///       // Add some code assets.
///     }
///   });
/// }
/// ```
///
/// For more information about build hooks see
/// [dart.dev/tools/hooks](https://dart.dev/tools/hooks).
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

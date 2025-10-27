// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @docImport 'src/api/build_and_link.dart';

/// This package provides the API for hooks in Dart. Hooks are Dart scripts
/// placed in the `hook/` directory of a Dart package, designed to automate
/// tasks for a Dart package.
///
/// Currently, the main supported hook is the build hook (`hook/build.dart`).
/// The build hook is executed during a Dart build and enables you to bundle
/// assets with a Dart package. The main entrypoint for build hooks is [build].
///
/// The second hook available in this API is the link hook  (`hook/link.dart`).
/// The main entrypoint for link hooks is [link].
///
/// Hooks can for example be used to bundle native source code with a Dart
/// package:
///
/// <!-- file://./../../code_assets/example/sqlite/hook/build.dart -->
/// ```dart
/// import 'package:code_assets/code_assets.dart';
/// import 'package:hooks/hooks.dart';
/// import 'package:native_toolchain_c/native_toolchain_c.dart';
///
/// void main(List<String> args) async {
///   await build(args, (input, output) async {
///     if (input.config.buildCodeAssets) {
///       final builder = CBuilder.library(
///         name: 'sqlite3',
///         assetName: 'src/third_party/sqlite3.g.dart',
///         sources: ['third_party/sqlite/sqlite3.c'],
///         defines: {
///           if (input.config.code.targetOS == OS.windows)
///             // Ensure symbols are exported in dll.
///             'SQLITE_API': '__declspec(dllexport)',
///         },
///       );
///       await builder.run(input: input, output: output);
///     }
///   });
/// }
/// ```
///
/// Hooks can also be used to bundle precompiled native code with a package:
///
/// <!-- file://./../../code_assets/example/api/code_assets_snippet.dart -->
/// ```dart
/// import 'package:code_assets/code_assets.dart';
/// import 'package:hooks/hooks.dart';
///
/// void main(List<String> args) async {
///   await build(args, (input, output) async {
///     if (input.config.buildCodeAssets) {
///       final packageName = input.packageName;
///       final assetPathInPackage = input.packageRoot.resolve('...');
///       final assetPathDownload = input.outputDirectoryShared.resolve('...');
///
///       output.assets.code.add(
///         CodeAsset(
///           package: packageName,
///           name: '...',
///           linkMode: DynamicLoadingBundled(),
///           file: assetPathInPackage,
///         ),
///       );
///     }
///   });
/// }
/// ```
///
/// For more information see
/// [dart.dev/tools/hooks](https://dart.dev/tools/hooks).
library;

export 'src/api/build_and_link.dart' show build, link;
export 'src/api/builder.dart' show Builder;
export 'src/api/linker.dart' show Linker;
export 'src/config.dart'
    show
        AssetRouting,
        BuildConfig,
        BuildConfigBuilder,
        BuildError,
        BuildInput,
        BuildInputAssets,
        BuildInputBuilder,
        BuildInputMetadata,
        BuildOutput,
        BuildOutputAssets,
        BuildOutputAssetsBuilder,
        BuildOutputBuilder,
        BuildOutputFailure,
        BuildOutputMaybeFailure,
        BuildOutputMetadataBuilder,
        FailureType,
        HookConfig,
        HookConfigBuilder,
        HookError,
        HookInput,
        HookInputBuilder,
        HookInputUserDefines,
        HookOutput,
        HookOutputBuilder,
        HookOutputDependenciesBuilder,
        HookOutputFailure,
        InfraError,
        LinkAssetRouting,
        LinkConfig,
        LinkConfigBuilder,
        LinkInput,
        LinkInputAssets,
        LinkInputBuilder,
        LinkOutput,
        LinkOutputAssets,
        LinkOutputAssetsBuilder,
        LinkOutputBuilder,
        LinkOutputFailure,
        LinkOutputMaybeFailure,
        LinkOutputMetadataBuilder,
        PackageMetadata,
        ToAppBundle,
        ToBuildHooks,
        ToLinkHook;
export 'src/encoded_asset.dart' show EncodedAsset;
export 'src/extension.dart';
export 'src/test.dart';
export 'src/user_defines.dart'
    show PackageUserDefines, PackageUserDefinesSource;
export 'src/validation.dart' show ProtocolBase;

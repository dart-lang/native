// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @docImport 'src/api/build_and_link.dart';

/// This package provides the API for hooks in Dart. Hooks are Dart scripts
/// placed in the `hook/` directory of a Dart package, designed to automate
/// tasks for a Dart package.
///
/// This API supports two hooks: the build hook (`hook/build.dart`) and the link
/// hook (`hook/link.dart`).
///
/// The build hook is executed during a Dart build and enables you to build or
/// gather assets for a Dart package. The main entrypoint for build hooks is
/// [build].
///
/// The link hook is executed after all build hooks and enables you to perform
/// whole-application optimization and linking (such as tree-shaking dead
/// native code based on
/// [`@RecordUse()`](https://pub.dev/documentation/meta/latest/meta/RecordUse-class.html)
/// usages). The main entrypoint for link hooks is [link].
///
/// Hooks can for example be used to compile native source code with a Dart
/// package using a build hook and a link hook. First, define the C library
/// specification in a shared file:
///
/// <!-- file://./../../code_assets/example/sqlite/lib/src/c_library.dart -->
/// ```dart
/// import 'package:native_toolchain_c/native_toolchain_c.dart';
///
/// /// The C build specification for the sqlite library.
/// ///
/// /// It is used by the build and link hooks in the `hook/` directory.
/// final cLibrary = CLibrary(
///   name: 'sqlite3',
///   assetName: 'src/third_party/sqlite3.g.dart',
///   sources: ['third_party/sqlite/sqlite3.c'],
/// );
/// ```
///
/// Next, compile the library in the build hook:
///
/// <!-- file://./../../code_assets/example/sqlite/hook/build.dart -->
/// ```dart
/// import 'package:code_assets/code_assets.dart';
/// import 'package:hooks/hooks.dart';
/// import 'package:sqlite/src/c_library.dart';
///
/// void main(List<String> args) async {
///   await build(args, (input, output) async {
///     if (input.config.buildCodeAssets) {
///       await cLibrary.build(
///         input: input,
///         output: output,
///         defines: {
///           if (input.config.code.targetOS == OS.windows)
///             // Ensure symbols are exported in dll.
///             'SQLITE_API': '__declspec(dllexport)',
///         },
///       );
///     }
///   });
/// }
/// ```
///
/// Finally, tree-shake and link the library in the link hook:
///
/// <!-- file://./../../code_assets/example/sqlite/hook/link.dart -->
/// ```dart
/// import 'package:hooks/hooks.dart';
/// import 'package:native_toolchain_c/native_toolchain_c.dart';
/// import 'package:record_use/record_use.dart';
/// import 'package:sqlite/src/c_library.dart';
/// import 'package:sqlite/src/third_party/record_use_mapping.dart';
///
/// void main(List<String> arguments) async {
///   await link(arguments, (input, output) async {
///     await cLibrary.link(
///       input: input,
///       output: output,
///       linkerOptions: LinkerOptions.treeshake(
///         symbolsToKeep: input.recordedUses?.calls.keys.cast<Method>().map(
///           (e) => recordUseMapping[e.name]!,
///         ),
///       ),
///     );
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
///
/// ## Environment
///
/// Hooks are executed in a semi-hermetic environment. This means that
/// `Platform.environment` does not expose all environment variables from the
/// parent process. This ensures that hook invocations are reproducible and
/// cacheable, and do not depend on accidental environment variables.
///
/// However, some environment variables are necessary for locating tools (like
/// compilers) or configuring network access. The following environment
/// variables are passed through to the hook process:
///
/// *   **Path and system roots:**
///     *   `PATH`: Invoke native tools.
///     *   `HOME`, `USERPROFILE`: Find tools in default install locations.
///     *   `SYSTEMDRIVE`, `SYSTEMROOT`, `WINDIR`: Process invocations and CMake
///         on Windows.
///     *   `PROGRAMDATA`: For `vswhere.exe` on Windows.
/// *   **Temporary directories:**
///     *   `TEMP`, `TMP`, `TMPDIR`: Temporary directories.
/// *   **HTTP proxies:**
///     *   `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`: Network access behind
///         proxies.
/// *   **Clang/LLVM:**
///     *   `LIBCLANG_PATH`: Rust's `bindgen` + `clang-sys`.
/// *   **Android NDK:**
///     *   `ANDROID_HOME`: Standard location for the Android SDK/NDK.
///     *   `ANDROID_NDK`, `ANDROID_NDK_HOME`, `ANDROID_NDK_LATEST_HOME`,
///         `ANDROID_NDK_ROOT`: Alternative locations for the NDK.
/// *   **Ccache:**
///     *   Any variable starting with `CCACHE_`.
/// *   **Nix:**
///     *   Any variable starting with `NIX_`.
///
/// Any changes to these environment variables will cause cache invalidation for
/// hooks.
///
/// All other environment variables are stripped.
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

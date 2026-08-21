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
/// This package is used in a build hook (`hook/build.dart`) or link hook
/// (`hook/link.dart`) to inform the Dart and Flutter SDKs about the code assets
/// that need to be bundled with an application.
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
/// When compiling C, C++ or Objective-C code from source, consider using
/// [`package:native_toolchain_c`](https://pub.dev/packages/native_toolchain_c)
/// with a build hook and a link hook. First, define the C library
/// specification in a shared file:
///
/// <!-- file://./../example/sqlite/lib/src/c_library.dart -->
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
/// <!-- file://./../example/sqlite/hook/build.dart -->
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
/// <!-- file://./../example/sqlite/hook/link.dart -->
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
/// See the full example in [example/sqlite/](../example/sqlite/).
///
/// When interfacing with system libraries, the API in this package is enough:
///
/// <!-- file://./../example/host_name/hook/build.dart -->
/// ```dart
/// import 'package:code_assets/code_assets.dart';
/// import 'package:hooks/hooks.dart';
///
/// void main(List<String> args) async {
///   await build(args, (input, output) async {
///     if (input.config.buildCodeAssets) {
///       switch (input.config.code.targetOS) {
///         case OS.android || OS.iOS || OS.linux || OS.macOS:
///           output.assets.code.add(
///             CodeAsset(
///               package: 'host_name',
///               name: 'src/third_party/unix.dart',
///               linkMode: LookupInProcess(),
///             ),
///           );
///         case OS.windows:
///           output.assets.code.add(
///             CodeAsset(
///               package: 'host_name',
///               name: 'src/third_party/windows.dart',
///               linkMode: DynamicLoadingSystem(Uri.file('ws2_32.dll')),
///             ),
///           );
///         case final os:
///           throw UnsupportedError('Unsupported OS: ${os.name}.');
///       }
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
/// For more information about build and link hooks see
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
export 'src/code_assets/sanitizer.dart' show Sanitizer;
export 'src/code_assets/testing.dart' show testCodeBuildHook;

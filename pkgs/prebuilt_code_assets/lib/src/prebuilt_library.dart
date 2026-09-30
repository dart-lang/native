// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

import 'build_options.dart';
import 'coff_archive.dart';
import 'fetch.dart';
import 'logging.dart';
import 'release_config.dart';
import 'source_builders.dart';
import 'symbols_resolver.dart';

/// Declarative specification for building, fetching, and tree-shaking a native
/// library across `hook/build.dart`, `hook/link.dart`, and standalone
/// maintainer scripts.
///
/// Modeled after `CLibrary` in `package:native_toolchain_c`, a single
/// [PrebuiltLibrary] instance can be defined in `lib/src/hook_helpers/` and
/// invoked from:
/// - `hook/build.dart` via [build]
/// - `hook/link.dart` via [link]
/// - `tool/precompile_binaries.dart` via [buildStandalone]
class PrebuiltLibrary {
  /// The library stem name passed to `OS.dylibFileName` and `CLinker.library`
  /// (e.g. `'my_lib'` for `libmy_lib.so`).
  final String name;

  /// Optional package name override. Defaults to `input.packageName`.
  final String? packageName;

  /// The `@Native` asset ID suffix (e.g. `'my_package.dart'` or
  /// `'src/bindings/lib.g.dart'`).
  final String assetName;

  /// Configuration for fetching and verifying prebuilt release binaries.
  final PrebuiltReleaseConfig? releaseConfig;

  /// Optional directory relative to `input.packageRoot` containing pub-bundled
  /// prebuilt binaries (e.g. `'prebuilt'`, following `prebuilt_assets_example`
  /// in `package:hooks`).
  final String? prebuiltDirectory;

  /// Callback to compile the native library from source when `buildMode` is
  /// `build` or when `fetch` falls back to building from source.
  final SourceBuildCallback? buildFromSource;

  /// Whether `fetch` mode should fall back to [buildFromSource] if no prebuilt
  /// binary is available for the target.
  final bool fallbackToBuildOnFetchFailure;

  /// Whether unrecognized `buildMode`/`treeshake` values in
  /// `hooks.user_defines` throw a [BuildError] (the default) instead of
  /// silently using the defaults.
  final bool strictBuildOptions;

  /// Extracts the native symbols used by the application from
  /// `LinkInput.recordedUses`.
  final SymbolsResolver? usedSymbols;

  /// Optional set of all bound symbol names (used on Windows when
  /// `LinkInput.recordedUses` is `null` or when filtering COFF archive
  /// symbols).
  final Iterable<String>? allKnownSymbols;

  /// Optional callback returning the system libraries to link against in
  /// [link] for the target [CodeConfig] (passed as `-l<name>`, or `<name>.lib`
  /// for MSVC).
  ///
  /// Static libraries don't record their dependencies, so this has to list
  /// every library that the static library needs and that the linker doesn't
  /// link by default (such as `ws2_32` on Windows or `m` on Android).
  final List<String> Function(CodeConfig code)? libraries;

  /// Optional callback returning the frameworks to link against in [link] for
  /// the target [CodeConfig] (passed as `-framework <name>`).
  ///
  /// Only used when targeting macOS or iOS. If `null`, uses the default of
  /// `CLinker` in `package:native_toolchain_c` (`Foundation`).
  final List<String> Function(CodeConfig code)? frameworks;

  /// Optimization level passed to `CLinker.library` in [link].
  final OptimizationLevel optimizationLevel;

  const PrebuiltLibrary({
    required this.name,
    this.packageName,
    required this.assetName,
    this.releaseConfig,
    this.prebuiltDirectory,
    this.buildFromSource,
    this.fallbackToBuildOnFetchFailure = true,
    this.strictBuildOptions = true,
    this.usedSymbols,
    this.allKnownSymbols,
    this.libraries,
    this.frameworks,
    this.optimizationLevel = OptimizationLevel.o3,
  });

  /// Runs the build hook (`hook/build.dart`) for this library.
  ///
  /// When linking is enabled (`input.config.linkingEnabled`), `buildMode` is
  /// not [NativeBuildMode.local], and `treeshake` is not
  /// [TreeshakeMode.off], obtains a static library and routes it to this
  /// package's link hook. Otherwise obtains a dynamic library and bundles it
  /// directly.
  ///
  /// In `fetch` mode, if no static library is available for the target and
  /// `treeshake` is [TreeshakeMode.auto], falls back to bundling the prebuilt
  /// dynamic library (with a warning) before trying [buildFromSource].
  Future<void> build({
    required BuildInput input,
    required BuildOutputBuilder output,
    List<Uri> additionalDependencies = const [],
    Logger? logger,
  }) async {
    final log = logger ?? defaultLogger;
    final pkg = packageName ?? input.packageName;
    if (!input.config.buildCodeAssets) {
      log.info(
        '$pkg: skipping native asset build (code assets not requested).',
      );
      return;
    }

    final buildOptions = _buildOptions(input, pkg);
    log.info('$pkg: $buildOptions');

    final static =
        input.config.linkingEnabled &&
        buildOptions.buildMode != NativeBuildMode.local &&
        buildOptions.treeshake != TreeshakeMode.off;

    switch (buildOptions.buildMode) {
      case NativeBuildMode.fetch:
        await _fetchOrFallback(
          input,
          output,
          pkg: pkg,
          static: static,
          options: buildOptions,
          log: log,
        );
      case NativeBuildMode.build:
        final builtUri = await _requireBuildFromSource(
          input,
          output,
          pkg: pkg,
          static: static,
          checkoutPath: buildOptions.checkoutPath,
        );
        _addLibrary(input, output, pkg: pkg, library: builtUri, static: static);
      case NativeBuildMode.local:
        await _useLocalBinary(
          input,
          output,
          pkg: pkg,
          localPath: buildOptions.localPath,
        );
    }

    output.dependencies.addAll([
      input.packageRoot.resolve('pubspec.yaml'),
      ...additionalDependencies,
    ]);
  }

  BuildOptions _buildOptions(HookInput input, String pkg) =>
      BuildOptions.fromDefines(
        input.userDefines,
        packageName: pkg,
        strict: strictBuildOptions,
      );

  Future<void> _fetchOrFallback(
    BuildInput input,
    BuildOutputBuilder output, {
    required String pkg,
    required bool static,
    required BuildOptions options,
    required Logger log,
  }) async {
    final config = releaseConfig;
    if (config != null) {
      final library = await _fetch(input, config, static: static, log: log);
      if (library != null) {
        _addLibrary(input, output, pkg: pkg, library: library, static: static);
        return;
      }

      // Tree-shaking only makes the library smaller, so in `auto` mode a
      // missing static library should not prevent using the dynamic one.
      if (static && options.treeshake == TreeshakeMode.auto) {
        final dynamic = await _fetch(input, config, static: false, log: log);
        if (dynamic != null) {
          log.warning(
            'Warning: package:$pkg has no pre-built static library for '
            '${_target(input)} in the ${config.version} release, so it '
            'bundles the pre-built dynamic library instead, which is not '
            'tree-shaken and therefore larger.',
          );
          _addLibrary(
            input,
            output,
            pkg: pkg,
            library: dynamic,
            static: false,
          );
          return;
        }
      }
    }

    if (buildFromSource != null &&
        (config == null || fallbackToBuildOnFetchFailure)) {
      if (config != null) {
        log.info('$pkg: falling back to building from source.');
      }
      final builtUri = await buildFromSource!(
        input,
        output,
        static: static,
        checkoutPath: options.checkoutPath,
      );
      _addLibrary(input, output, pkg: pkg, library: builtUri, static: static);
      return;
    }

    throw BuildError(
      message: config == null
          ? '$pkg: neither `releaseConfig` nor `buildFromSource` is '
                'configured on PrebuiltLibrary.'
          : '$pkg: failed to fetch a pre-built '
                '${static ? 'static' : 'dynamic'} library for '
                '${_target(input)}.',
    );
  }

  Future<Uri?> _fetch(
    HookInput input,
    PrebuiltReleaseConfig config, {
    required bool static,
    required Logger log,
  }) => fetchPrebuiltLibrary(
    input,
    config,
    static: static,
    prebuiltDirectory: prebuiltDirectory,
    canBuildFromSource: buildFromSource != null,
    logger: log,
  );

  Future<Uri> _requireBuildFromSource(
    BuildInput input,
    BuildOutputBuilder output, {
    required String pkg,
    required bool static,
    required Uri? checkoutPath,
  }) async {
    final callback = buildFromSource;
    if (callback == null) {
      throw BuildError(
        message:
            '$pkg: `buildMode: build` requires building from source, but '
            'this package does not support building from source.',
      );
    }
    return callback(input, output, static: static, checkoutPath: checkoutPath);
  }

  Future<void> _useLocalBinary(
    BuildInput input,
    BuildOutputBuilder output, {
    required String pkg,
    required Uri? localPath,
  }) async {
    if (localPath == null) {
      throw BuildError(
        message:
            'buildMode is set to `local`, but `localPath` was not specified '
            'under `hooks.user_defines.$pkg`.',
      );
    }
    final file = File.fromUri(localPath);
    if (!file.existsSync()) {
      throw BuildError(
        message:
            'Specified local binary does not exist at '
            '${localPath.toFilePath()}',
      );
    }
    final dylibFileName = input.config.code.targetOS.dylibFileName(name);
    final destFile = File.fromUri(input.outputDirectory.resolve(dylibFileName));
    await destFile.parent.create(recursive: true);
    await file.copy(destFile.path);

    _addLibrary(
      input,
      output,
      pkg: pkg,
      library: destFile.uri,
      static: false,
    );
    output.dependencies.add(localPath);
  }

  void _addLibrary(
    BuildInput input,
    BuildOutputBuilder output, {
    required String pkg,
    required Uri library,
    required bool static,
  }) {
    output.assets.code.add(
      CodeAsset(
        package: pkg,
        name: assetName,
        linkMode: static ? StaticLinking() : DynamicLoadingBundled(),
        file: library,
      ),
      routing: static ? ToLinkHook(input.packageName) : const ToAppBundle(),
    );
  }

  /// Runs the link hook (`hook/link.dart`) to link and tree-shake the static
  /// library emitted by [build] into a dynamic library containing only the
  /// functions referenced in `input.recordedUses`.
  ///
  /// All other assets sent to this link hook are forwarded unchanged.
  ///
  /// Behavior is controlled by `hooks.user_defines.<package>.treeshake`:
  /// - [TreeshakeMode.auto] (default): Tries to tree-shake, and if linking
  ///   fails in [NativeBuildMode.fetch], prints a warning and falls back to
  ///   bundling the prebuilt dynamic library.
  /// - [TreeshakeMode.on]: Always tries to tree-shake, and rethrows if linking
  ///   fails.
  /// - [TreeshakeMode.off]: Never tree-shakes. [build] then bundles the
  ///   dynamic library directly; if a static library still reaches [link], the
  ///   prebuilt dynamic library is bundled instead.
  Future<void> link({
    required LinkInput input,
    required LinkOutputBuilder output,
    Logger? logger,
  }) async {
    final log = logger ?? defaultLogger;
    final pkg = packageName ?? input.packageName;
    final expectedId = 'package:$pkg/$assetName';

    CodeAsset? staticLibrary;
    for (final encoded in input.assets.encodedAssets) {
      if (staticLibrary == null && encoded.isCodeAsset) {
        final asset = CodeAsset.fromEncoded(encoded);
        if (asset.id == expectedId && asset.linkMode is StaticLinking) {
          staticLibrary = asset;
          continue;
        }
      }
      output.assets.addEncodedAsset(encoded);
    }
    if (staticLibrary == null) {
      // hook/build.dart bundled a dynamic library directly.
      return;
    }

    final buildOptions = _buildOptions(input, pkg);

    if (buildOptions.treeshake == TreeshakeMode.off) {
      log.info('$pkg: treeshake is off, skipping C linker.');
      if (await _bundlePrebuiltDynamicLibrary(input, output, pkg, log)) {
        return;
      }
      throw BuildError(
        message:
            '$pkg: treeshake is off, but no pre-built dynamic library is '
            'available for ${_target(input)} to bundle instead of the static '
            'library.',
      );
    }

    final staticLibraryFile = staticLibrary.file!;

    final recordedUses = input.recordedUses;
    final List<String>? symbols;
    if (recordedUses == null || usedSymbols == null) {
      log.info('$pkg: no recorded uses, keeping all functions.');
      symbols = null;
    } else {
      symbols = usedSymbols!(recordedUses);
      log.info(
        '$pkg: keeping the ${symbols.length} functions the application '
        'uses:\n  ${symbols.join('\n  ')}',
      );
    }

    try {
      await _linkStaticLibrary(
        input,
        output,
        pkg: pkg,
        staticLibrary: staticLibraryFile,
        symbols: symbols,
        log: log,
      );
    } catch (e, s) {
      log.info('$pkg: linking failed: $e\n$s');
      if (buildOptions.treeshake == TreeshakeMode.on) {
        rethrow;
      }
      // Tree-shaking only makes the library smaller, so in `auto` mode a
      // missing or broken C toolchain should not fail the build if there is an
      // equivalent pre-built dynamic library. This also catches Error (such as
      // ToolError).
      final fellBack = await _fallBackToPrebuiltLibrary(
        input,
        output,
        pkg: pkg,
        buildMode: buildOptions.buildMode,
        error: e,
        log: log,
      );
      if (!fellBack) {
        rethrow;
      }
    }
  }

  /// Links [staticLibrary] into a dynamic library exporting [symbols] (or all
  /// functions if `null`).
  Future<void> _linkStaticLibrary(
    LinkInput input,
    LinkOutputBuilder output, {
    required String pkg,
    required Uri staticLibrary,
    required List<String>? symbols,
    required Logger log,
  }) async {
    final code = input.config.code;
    final linkerOptions = code.targetOS == OS.windows
        ? await createWindowsLinkerOptions(
            outputDirectory: input.outputDirectory,
            libraryName: name,
            staticLibrary: staticLibrary,
            symbols: symbols,
            allKnownSymbols: allKnownSymbols,
          )
        : LinkerOptions.treeshake(symbolsToKeep: symbols);
    final linkLibraries = libraries?.call(code) ?? const <String>[];
    final linkFrameworks = frameworks?.call(code);
    final linker = linkFrameworks == null
        // Omit `frameworks` to keep the default of `CLinker`.
        ? CLinker.library(
            name: name,
            packageName: pkg,
            assetName: assetName,
            sources: [staticLibrary.toFilePath()],
            libraries: linkLibraries,
            optimizationLevel: optimizationLevel,
            linkerOptions: linkerOptions,
            linkModePreference: LinkModePreference.dynamic,
          )
        : CLinker.library(
            name: name,
            packageName: pkg,
            assetName: assetName,
            sources: [staticLibrary.toFilePath()],
            libraries: linkLibraries,
            frameworks: linkFrameworks,
            optimizationLevel: optimizationLevel,
            linkerOptions: linkerOptions,
            linkModePreference: LinkModePreference.dynamic,
          );
    await linker.run(input: input, output: output, logger: log);
  }

  Future<bool> _bundlePrebuiltDynamicLibrary(
    LinkInput input,
    LinkOutputBuilder output,
    String pkg,
    Logger log,
  ) async {
    final config = releaseConfig;
    if (config == null) {
      return false;
    }
    final library = await _fetch(input, config, static: false, log: log);
    if (library == null) {
      return false;
    }
    output.assets.code.add(
      CodeAsset(
        package: pkg,
        name: assetName,
        linkMode: DynamicLoadingBundled(),
        file: library,
      ),
    );
    return true;
  }

  Future<bool> _fallBackToPrebuiltLibrary(
    LinkInput input,
    LinkOutputBuilder output, {
    required String pkg,
    required NativeBuildMode buildMode,
    required Object error,
    required Logger log,
  }) async {
    final target = _target(input);

    if (buildMode != NativeBuildMode.fetch) {
      log.severe(
        'package:$pkg could not link the static library built in the '
        '`${buildMode.name}` build mode for $target. Install a C toolchain '
        '(compiler and linker) for $target. Only the `fetch` build mode falls '
        'back to the pre-built dynamic library, which could differ from the '
        'library built in other modes.',
      );
      return false;
    }

    final reason = switch (error) {
      ProcessException(:final executable) =>
        'ProcessException: $executable failed',
      _ => error.toString().split('\n').first,
    };
    if (!await _bundlePrebuiltDynamicLibrary(input, output, pkg, log)) {
      return false;
    }
    log.warning(
      'Warning: package:$pkg could not tree-shake its native library for '
      '$target, so it bundles the pre-built dynamic library of the $pkg '
      '${releaseConfig!.version} release instead, which is not tree-shaken '
      'and therefore larger. To enable tree-shaking, install a C toolchain '
      '(compiler and linker) for $target. Linking failed with: $reason',
    );
    return true;
  }

  static String _target(HookInput input) {
    final code = input.config.code;
    return '${code.targetOS}_${code.targetArchitecture}';
  }

  /// Synthesizes a [BuildInput] via [BuildInputBuilder] (following the
  /// `download_asset/tool/build.dart` pattern in `package:hooks`) and invokes
  /// [buildFromSource] for standalone precompilation in CI scripts.
  ///
  /// [packageName] defaults to [PrebuiltLibrary.packageName], then to [name].
  Future<Uri> buildStandalone({
    required OS targetOS,
    required Architecture targetArchitecture,
    required bool static,
    IOSSdk? iOSSdk,
    String? packageName,
    Uri? packageRoot,
    Uri? outputDirectory,
    Uri? outputDirectoryShared,
    Uri? checkoutPath,
    int androidTargetNdkApi = 28,
    int iOSTargetVersion = 13,
    int macOSTargetVersion = 13,
  }) async {
    final callback = buildFromSource;
    if (callback == null) {
      throw StateError(
        'Cannot call buildStandalone when `buildFromSource` is null.',
      );
    }
    final root = packageRoot ?? Directory.current.uri;
    final pkg = packageName ?? this.packageName ?? name;
    final outDir =
        outputDirectory ??
        root.resolve(
          '.dart_tool/prebuilt_code_assets/'
          '${targetOS.name}_${targetArchitecture.name}_'
          '${static ? "static" : "dynamic"}/',
        );
    final sharedDir =
        outputDirectoryShared ??
        root.resolve('.dart_tool/prebuilt_code_assets/shared/');
    final outFile = outDir.resolve('output.json');

    await Directory.fromUri(outDir).create(recursive: true);
    await Directory.fromUri(sharedDir).create(recursive: true);

    final inputBuilder = BuildInputBuilder()
      ..setupShared(
        packageRoot: root,
        packageName: pkg,
        outputFile: outFile,
        outputDirectoryShared: sharedDir,
      )
      ..config.setupBuild(linkingEnabled: static)
      ..addExtension(
        CodeAssetExtension(
          targetArchitecture: targetArchitecture,
          targetOS: targetOS,
          linkModePreference: static
              ? LinkModePreference.static
              : LinkModePreference.dynamic,
          android: targetOS == OS.android
              ? AndroidCodeConfig(targetNdkApi: androidTargetNdkApi)
              : null,
          iOS: targetOS == OS.iOS
              ? IOSCodeConfig(
                  targetSdk: iOSSdk ?? IOSSdk.iPhoneOS,
                  targetVersion: iOSTargetVersion,
                )
              : null,
          macOS: targetOS == OS.macOS
              ? MacOSCodeConfig(targetVersion: macOSTargetVersion)
              : null,
        ),
      );

    return callback(
      inputBuilder.build(),
      BuildOutputBuilder(),
      static: static,
      checkoutPath: checkoutPath,
    );
  }
}

// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';

import 'cbuilder.dart';
import 'clinker.dart';
import 'ctool.dart';
import 'language.dart';
import 'linker_options.dart';
import 'optimization_level.dart';

/// Specification for building and linking a library with a C compiler.
///
/// The [CLibrary] is used if we want to split building and linking C code
/// across a build and link hook. It abstracts over the [CBuilder] and
/// [CLinker] so that the plumbing doesn't have to be manual.
///
/// Use [CLibrary] in a shared file (e.g. `lib/src/c_library.dart`) and call
/// [build] from your build hook (`hook/build.dart`) and [link] from your
/// link hook (`hook/link.dart`).
///
/// If you don't need to support link-time optimization (LTO) or other linking
/// features that require a link hook, you can use [CBuilder] directly in your
/// build hook.
class CLibrary {
  /// Name of the library or executable to build or link.
  final String name;

  /// The package name to associate the asset with.
  final String? packageName;

  /// Asset identifier.
  final String? assetName;

  /// Sources to build the library or executable.
  final List<String> sources;

  /// Include directories to pass to the compiler.
  final List<String> includes;

  /// Files passed to the compiler that will be included before all source
  /// files.
  final List<String> forcedIncludes;

  /// Frameworks to link.
  final List<String> frameworks;

  /// Libraries to link to.
  final List<String> libraries;

  /// Directories to search for [libraries].
  final List<String> libraryDirectories;

  /// Flags to pass to the build tool.
  final List<String> flags;

  /// Definitions of preprocessor macros.
  final Map<String, String?> defines;

  /// Whether the linker will emit position independent code.
  final bool? pic;

  /// The language standard to use.
  final String? std;

  /// The language to compile [sources] as.
  final Language language;

  /// The C++ standard library to link against.
  final String? cppLinkStdLib;

  /// What optimization level should be used for compiling.
  final OptimizationLevel optimizationLevel;

  /// Whether to define a macro for the current build mode.
  final bool buildModeDefine;

  /// Whether to define the standard `NDEBUG` macro.
  final bool ndebugDefine;

  CLibrary({
    required this.name,
    this.packageName,
    this.assetName,
    this.sources = const [],
    this.includes = const [],
    this.forcedIncludes = const [],
    this.frameworks = CTool.defaultFrameworks,
    this.libraries = const [],
    this.libraryDirectories = CTool.defaultLibraryDirectories,
    this.flags = const [],
    this.defines = const {},
    this.pic = true,
    this.std,
    this.language = Language.c,
    this.cppLinkStdLib,
    this.optimizationLevel = OptimizationLevel.o3,
    this.buildModeDefine = true,
    this.ndebugDefine = true,
  });

  late final _builder = CBuilder.library(
    name: name,
    packageName: packageName,
    assetName: assetName,
    sources: sources,
    includes: includes,
    forcedIncludes: forcedIncludes,
    frameworks: frameworks,
    libraries: libraries,
    libraryDirectories: libraryDirectories,
    flags: flags,
    defines: defines,
    pic: pic,
    std: std,
    language: language,
    cppLinkStdLib: cppLinkStdLib,
    optimizationLevel: optimizationLevel,
    buildModeDefine: buildModeDefine,
    ndebugDefine: ndebugDefine,
  );

  late final _linker = CLinker.library(
    name: name,
    packageName: packageName,
    assetName: assetName,
    includes: includes,
    forcedIncludes: forcedIncludes,
    frameworks: frameworks,
    libraries: libraries,
    libraryDirectories: libraryDirectories,
    flags: flags,
    defines: defines,
    pic: pic,
    std: std,
    language: language,
    cppLinkStdLib: cppLinkStdLib,
    optimizationLevel: optimizationLevel,
  );

  /// Builds the C code.
  ///
  /// This should be called from your build hook (`hook/build.dart`).
  ///
  /// It takes the [input] and [output] from the build hook.
  ///
  /// By default, the output is routed to a link hook in the same package, and
  /// the link mode is set to static, so the linker can perform optimizations.
  ///
  /// If provided, uses [logger] to output logs. Otherwise, uses a default
  /// logger that streams [Level.WARNING] to stdout and higher levels to stderr.
  ///
  /// [routing] determines how the built assets are distributed. Defaults to
  /// [ToLinkHook] if linking is enabled, otherwise [ToAppBundle].
  ///
  /// [linkModePreference] overrides the default link mode (which is static
  /// if linking is enabled, otherwise dynamic).
  ///
  /// [defines] are merged with the [CLibrary.defines] of this [CLibrary]. See
  /// [CLibrary.defines] for more documentation.
  Future<void> build({
    required BuildInput input,
    required BuildOutputBuilder output,
    Logger? logger,
    List<AssetRouting>? routing,
    LinkModePreference? linkModePreference,
    Map<String, String?>? defines,
  }) async {
    final builder = defines == null
        ? _builder
        : CBuilder.library(
            name: name,
            packageName: packageName,
            assetName: assetName,
            sources: sources,
            includes: includes,
            forcedIncludes: forcedIncludes,
            frameworks: frameworks,
            libraries: libraries,
            libraryDirectories: libraryDirectories,
            flags: flags,
            defines: {...this.defines, ...defines},
            pic: pic,
            std: std,
            language: language,
            cppLinkStdLib: cppLinkStdLib,
            optimizationLevel: optimizationLevel,
            buildModeDefine: buildModeDefine,
            ndebugDefine: ndebugDefine,
          );
    await builder.run(
      input: input,
      output: output,
      logger: logger,
      routing:
          routing ??
          (input.config.linkingEnabled
              ? [ToLinkHook(input.packageName)]
              : [const ToAppBundle()]),
      linkModePreference:
          linkModePreference ??
          (input.config.linkingEnabled
              ? LinkModePreference.static
              : LinkModePreference.dynamic),
    );
  }

  /// Links the C code.
  ///
  /// This should be called from your link hook (`hook/link.dart`).
  ///
  /// It takes the [input] and [output] from the link hook.
  ///
  /// By default, it links all the code assets that were produced by the build
  /// step. If [assetName] is set, only code assets matching that name are
  /// linked.
  ///
  /// If provided, uses [logger] to output logs. Otherwise, uses a default
  /// logger that streams [Level.WARNING] to stdout and higher levels to stderr.
  ///
  /// [linkerOptions] overrides the [CLinker.linkerOptions] of the internal
  /// linker. See [CLinker.linkerOptions] for more documentation.
  ///
  /// [linkModePreference] overrides the default link mode preference from the
  /// build configuration.
  ///
  /// [defines] are merged with the [CLibrary.defines] of this [CLibrary]. See
  /// [CLibrary.defines] for more documentation.
  Future<void> link({
    required LinkInput input,
    required LinkOutputBuilder output,
    Logger? logger,
    LinkerOptions? linkerOptions,
    LinkModePreference? linkModePreference,
    Map<String, String?>? defines,
  }) async {
    // If we have an assetName, we use that to find the assets.
    final assets = assetName != null
        ? input.assets.code.where((a) => a.id.endsWith(assetName!))
        : input.assets.code;

    await _linker.run(
      input: input,
      output: output,
      logger: logger,
      linkerOptions: linkerOptions,
      linkModePreference: linkModePreference,
      sources: assets.map((a) => a.file!.toFilePath()).toList(),
      defines: defines,
    );
  }
}

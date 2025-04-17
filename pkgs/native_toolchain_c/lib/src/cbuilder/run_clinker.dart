// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/code_assets.dart';

import '../native_toolchain/tool_likeness.dart';
import '../native_toolchain/xcode.dart';
import '../tool/tool_instance.dart';
import '../utils/run_process.dart';
import 'compiler_resolver.dart';
import 'language.dart';
import 'linker_options.dart';
import 'optimization_level.dart';

class RunCLinker {
  /// The options are for linking only, so this will be non-null iff a linker
  /// should be run.
  final LinkerOptions? linkerOptions;
  final HookInput input;
  final CodeConfig codeConfig;
  final Logger? logger;
  final List<Uri> sources;
  final List<Uri> includes;
  final List<Uri> forcedIncludes;
  final List<String> frameworks;
  final List<String> libraries;
  final List<Uri> libraryDirectories;
  final Uri? executable;
  final Uri? dynamicLibrary;
  final Uri? staticLibrary;
  final Uri outDir;

  /// The install name of the [dynamicLibrary].
  ///
  /// Can be inspected with `otool -D <path-to-dylib>`.
  ///
  /// Can be modified with `install_name_tool`.
  final Uri? installName;

  final List<String> flags;
  final Map<String, String?> defines;
  final bool? pic;
  final String? std;
  final Language language;
  final String? cppLinkStdLib;
  final OptimizationLevel optimizationLevel;

  RunCLinker({
    required this.input,
    required this.codeConfig,
    this.linkerOptions,
    this.logger,
    this.sources = const [],
    this.includes = const [],
    this.forcedIncludes = const [],
    required this.frameworks,
    this.libraries = const [],
    this.libraryDirectories = const [],
    this.executable,
    this.dynamicLibrary,
    this.staticLibrary,
    this.installName,
    this.flags = const [],
    this.defines = const {},
    this.pic,
    this.std,
    this.language = Language.c,
    this.cppLinkStdLib,
    required this.optimizationLevel,
  }) : outDir = input.outputDirectory,
       assert(
         [executable, dynamicLibrary, staticLibrary].whereType<Uri>().length ==
             1,
       ) {
    if (codeConfig.targetOS == OS.windows && cppLinkStdLib != null) {
      throw ArgumentError.value(
        cppLinkStdLib,
        'cppLinkStdLib',
        'is not supported when targeting Windows',
      );
    }
  }

  late final _resolver = CompilerResolver(
    codeConfig: codeConfig,
    logger: logger,
  );

  Future<ToolInstance> compiler() async => await _resolver.resolveCompiler();

  Future<Uri> archiver() async => (await _resolver.resolveArchiver()).uri;

  Future<ToolInstance> linker() async => await _resolver.resolveLinker();

  Future<Uri> iosSdk(IOSSdk iosSdk, {required Logger? logger}) async {
    if (iosSdk == IOSSdk.iPhoneOS) {
      return (await iPhoneOSSdk.defaultResolver!.resolve(
        logger: logger,
      )).where((i) => i.tool == iPhoneOSSdk).first.uri;
    }
    assert(iosSdk == IOSSdk.iPhoneSimulator);
    return (await iPhoneSimulatorSdk.defaultResolver!.resolve(
      logger: logger,
    )).where((i) => i.tool == iPhoneSimulatorSdk).first.uri;
  }

  Future<Uri> macosSdk({required Logger? logger}) async =>
      (await macosxSdk.defaultResolver!.resolve(
        logger: logger,
      )).where((i) => i.tool == macosxSdk).first.uri;

  Uri androidSysroot(ToolInstance compiler) =>
      compiler.uri.resolve('../sysroot/');

  Future<void> runLinker() async {
    assert(linkerOptions != null);
    final toolInstance_ = await linker();
    final tool = toolInstance_.tool;
    if (tool.isClangLike || tool.isLdLike) {
      await linkClangLike(tool: toolInstance_);
      return;
    } else {
      throw UnimplementedError('This package does not know how to run $tool.');
    }
  }

  Future<void> linkClangLike({required ToolInstance tool}) async {
    // Clang for Windows requires the MSVC Developer Environment.
    final environment = await _resolver.resolveEnvironment(tool);

    assert(staticLibrary == null);

    // The Android Gradle plugin does not honor API level 19 and 20 when
    // invoking clang. Mimic that behavior here.
    // See https://github.com/dart-lang/native/issues/171.
    final targetMacOSVersion =
        codeConfig.targetOS == OS.macOS ? codeConfig.macOS.targetVersion : null;

    final Iterable<String> sourceFiles =
        sources.map((e) => e.toFilePath()).toList();
    final outFile =
        dynamicLibrary != null ? outDir.resolveUri(dynamicLibrary!) : null;

    await runProcess(
      executable: tool.uri,
      environment: environment,
      arguments: [
        if (installName != null) ...[
          '-install_name',
          installName!.toFilePath(),
        ],
        if (targetMacOSVersion != null) ...[
          '-macos_version_min',
          '$targetMacOSVersion',
        ],
        '-dylib',
        ...['-arch', appleLdArchs[codeConfig.targetArchitecture]!],
        if (pic != null)
          if (tool.tool.isClangLike && codeConfig.targetOS != OS.windows) ...[
            if (pic!) ...[
              if (dynamicLibrary != null) '-fPIC',
              if (executable != null) ...[
                // Generate position-independent code for executables.
                '-fPIE',
                // Tell the linker to generate a position-independent
                // executable.
                '-pie',
              ],
            ] else ...[
              // Disable generation of any kind of position-independent code.
              '-fno-PIC',
              '-fno-PIE',
              // Tell the linker to generate a position-dependent executable.
              if (executable != null) '-no-pie',
            ],
          ] else if (tool.tool.isLdLike) ...[
            if (pic!) ...[
              if (executable != null) '--pie',
            ] else ...[
              if (executable != null) '--no-pie',
            ],
          ],
        if (std != null) '-std=$std',
        if (language == Language.cpp) ...[
          '-x',
          'c++',
          '-l',
          cppLinkStdLib ?? defaultCppLinkStdLib[codeConfig.targetOS]!,
        ],
        if (codeConfig.targetOS == OS.macOS) ...[
          '-syslibroot',
          (await macosSdk(logger: logger)).toFilePath(),
        ],
        if (optimizationLevel != OptimizationLevel.unspecified)
          optimizationLevel.clangFlag(),
        ...linkerOptions?.toLinkerSyntax(
              tool.tool,
              (sourceFiles.any((source) => source.endsWith('.a')) ||
                          linkerOptions!.includeAllSymbols) &&
                      OS.current == OS.linux
                  ? ['--whole-archive']
                  : [],
            ) ??
            [],
        // Support Android 15 page size by default, can be overridden by
        // passing [flags].
        if (codeConfig.targetOS == OS.android) '-Wl,-z,max-page-size=16384',
        ...flags,
        for (final MapEntry(key: name, :value) in defines.entries)
          if (value == null) '-D$name' else '-D$name=$value',
        for (final include in includes) '-I${include.toFilePath()}',
        for (final forcedInclude in forcedIncludes)
          '-include${forcedInclude.toFilePath()}',
        ...(linkerOptions != null
            ? switch (OS.current) {
              OS.linux => sourceFiles,
              OS.macOS => sourceFiles.expand(
                (source) =>
                    source.endsWith('.a')
                        ? [
                          if (linkerOptions!.includeAllSymbols)
                            linkerOptions!.toLinkerSyntax(tool.tool, [
                              '-force_load',
                            ]).first,
                          source,
                        ]
                        : [source],
              ),
              OS() => sourceFiles,
            }
            : sourceFiles),
        if (language == Language.objectiveC) ...[
          for (final framework in frameworks) ...['-framework', framework],
        ],
        if (executable != null) ...[
          '-o',
          outDir.resolveUri(executable!).toFilePath(),
        ] else if (dynamicLibrary != null) ...[
          '-o',
          outFile!.toFilePath(),
        ] else if (staticLibrary != null) ...[
          '-c',
          '-o',
          outFile!.toFilePath(),
        ],
        ...linkerOptions?.toLinkerSyntax(tool.tool, [
              ...[
                ...linkerOptions!.linkerFlags,
                if (OS.current == OS.macOS) '-lSystem',
              ],
              if (linkerOptions!.stripDebug)
                switch (OS.current) {
                  OS.linux => '--strip-debug',
                  OS.macOS => '-S',
                  OS() => throw UnimplementedError(),
                },
              if (linkerOptions!.gcSections)
                OS.current == OS.macOS ? '-dead_strip' : '--gc-sections',
              if (linkerOptions!.linkerScript != null && OS.current == OS.linux)
                '--version-script=${linkerOptions!.linkerScript!.toFilePath()}',
              if ((sourceFiles.any((source) => source.endsWith('.a')) ||
                      linkerOptions!.includeAllSymbols) &&
                  OS.current == OS.linux)
                '--no-whole-archive',
            ]) ??
            [],
        if (executable != null || dynamicLibrary != null) ...[
          if (codeConfig.targetOS case OS.android || OS.linux)
            // During bundling code assets are all placed in the same directory.
            // Setting this rpath allows the binary to find other code assets
            // it is linked against.
            if (linkerOptions != null)
              '-rpath=\$ORIGIN'
            else
              '-Wl,-rpath=\$ORIGIN',
          for (final directory in libraryDirectories)
            '-L${directory.toFilePath()}',
          for (final library in libraries) '-l$library',
        ],
      ],
      logger: logger,
      captureOutput: false,
      throwOnUnexpectedExitCode: true,
    );
  }

  static const appleLdArchs = {
    Architecture.arm64: 'arm64',
    Architecture.x64: 'x86_64',
  };

  static const defaultCppLinkStdLib = {
    OS.android: 'c++_shared',
    OS.fuchsia: 'c++',
    OS.iOS: 'c++',
    OS.linux: 'stdc++',
    OS.macOS: 'c++',
  };
}

// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import '../../native_toolchain_c.dart';
import '../native_toolchain/apple_clang.dart';
import '../native_toolchain/clang.dart';
import '../native_toolchain/gcc.dart';
import '../native_toolchain/xcode.dart';
import '../tool/tool_instance.dart';
import '../utils/run_process.dart';
import 'compiler_resolver.dart';

class RunCLinker {
  final LinkConfig linkConfig;
  final LinkerOptions linkerOptions;
  final Logger? logger;
  final List<Uri> sources;
  final List<Uri> includes;
  final List<String> frameworks;
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

  RunCLinker({
    required this.linkConfig,
    required this.linkerOptions,
    this.logger,
    this.sources = const [],
    this.includes = const [],
    required this.frameworks,
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
  })  : outDir = linkConfig.outputDirectory,
        assert([executable, dynamicLibrary, staticLibrary]
                .whereType<Uri>()
                .length ==
            1) {
    if (linkConfig.targetOS == OS.windows && cppLinkStdLib != null) {
      throw ArgumentError.value(
        cppLinkStdLib,
        'cppLinkStdLib',
        'is not supported when targeting Windows',
      );
    }
  }

  late final _resolver =
      CompilerResolver(hookConfig: linkConfig, logger: logger);

  Future<ToolInstance> compiler() async => await _resolver.resolveCompiler();

  Future<Uri> archiver() async => (await _resolver.resolveArchiver()).uri;

  Future<ToolInstance> linker() async => await _resolver.resolveLinker();

  Future<Uri> iosSdk(IOSSdk iosSdk, {required Logger? logger}) async {
    if (iosSdk == IOSSdk.iPhoneOS) {
      return (await iPhoneOSSdk.defaultResolver!.resolve(logger: logger))
          .where((i) => i.tool == iPhoneOSSdk)
          .first
          .uri;
    }
    assert(iosSdk == IOSSdk.iPhoneSimulator);
    return (await iPhoneSimulatorSdk.defaultResolver!.resolve(logger: logger))
        .where((i) => i.tool == iPhoneSimulatorSdk)
        .first
        .uri;
  }

  Future<Uri> macosSdk({required Logger? logger}) async =>
      (await macosxSdk.defaultResolver!.resolve(logger: logger))
          .where((i) => i.tool == macosxSdk)
          .first
          .uri;

  Uri androidSysroot(ToolInstance compiler) =>
      compiler.uri.resolve('../sysroot/');

  Future<void> run() async {
    final linker_ = await linker();
    final linkerTool = linker_.tool;
    if (linkerTool == appleClang ||
        linkerTool == clang ||
        linkerTool == gcc ||
        linkerTool == gnuLinker) {
      await runClangLike(tool: linker_);
      return;
    }
    throw UnimplementedError();
  }

  Future<void> runClangLike({required ToolInstance tool}) async {
    final isStaticLib = staticLibrary != null;
    Uri? archiver_;
    if (isStaticLib) {
      archiver_ = await archiver();
    }

    final IOSSdk? targetIosSdk;
    if (linkConfig.targetOS == OS.iOS) {
      targetIosSdk = linkConfig.targetIOSSdk;
    } else {
      targetIosSdk = null;
    }

    // The Android Gradle plugin does not honor API level 19 and 20 when
    // invoking clang. Mimic that behavior here.
    // See https://github.com/dart-lang/native/issues/171.
    final int? targetAndroidNdkApi;
    if (linkConfig.targetOS == OS.android) {
      final minimumApi =
          linkConfig.targetArchitecture == Architecture.riscv64 ? 35 : 21;
      targetAndroidNdkApi = max(linkConfig.targetAndroidNdkApi!, minimumApi);
    } else {
      targetAndroidNdkApi = null;
    }

    final targetIOSVersion =
        linkConfig.targetOS == OS.iOS ? linkConfig.targetIOSVersion : null;
    final targetMacOSVersion =
        linkConfig.targetOS == OS.macOS ? linkConfig.targetMacOSVersion : null;

    final architecture = linkConfig.targetArchitecture;
    final sourceFiles = sources.map((e) => e.toFilePath()).toList();
    final objectFiles = <Uri>[];
    if (staticLibrary != null) {
      for (var i = 0; i < sourceFiles.length; i++) {
        final objectFile = outDir.resolve('out$i.o');
        await _compile(
          tool,
          architecture,
          targetAndroidNdkApi,
          targetIosSdk,
          targetIOSVersion,
          targetMacOSVersion,
          [sourceFiles[i]],
          objectFile,
        );
        objectFiles.add(objectFile);
      }
      await runProcess(
        executable: archiver_!,
        arguments: [
          'rc',
          outDir.resolveUri(staticLibrary!).toFilePath(),
          ...objectFiles.map((objectFile) => objectFile.toFilePath()),
        ],
        logger: logger,
        captureOutput: false,
        throwOnUnexpectedExitCode: true,
      );
    } else {
      await _compile(
        tool,
        architecture,
        targetAndroidNdkApi,
        targetIosSdk,
        targetIOSVersion,
        targetMacOSVersion,
        sourceFiles,
        dynamicLibrary != null ? outDir.resolveUri(dynamicLibrary!) : null,
      );
    }
  }

  Future<void> _compile(
    ToolInstance compiler,
    Architecture? architecture,
    int? targetAndroidNdkApi,
    IOSSdk? targetIosSdk,
    int? targetIOSVersion,
    int? targetMacOSVersion,
    Iterable<String> sourceFiles,
    Uri? outFile,
  ) async {
    await runProcess(
      executable: compiler.uri,
      arguments: [
        if (linkConfig.targetOS == OS.android) ...[
          '--target='
              '${androidNdkClangTargetFlags[architecture]!}'
              '${targetAndroidNdkApi!}',
          '--sysroot=${androidSysroot(compiler).toFilePath()}',
        ],
        if (linkConfig.targetOS == OS.macOS)
          '--target=${appleClangMacosTargetFlags[architecture]!}',
        if (linkConfig.targetOS == OS.iOS)
          '--target=${appleClangIosTargetFlags[architecture]![targetIosSdk]!}',
        if (targetIOSVersion != null) '-mios-version-min=$targetIOSVersion',
        if (targetMacOSVersion != null)
          '-mmacos-version-min=$targetMacOSVersion',
        if (linkConfig.targetOS == OS.iOS) ...[
          '-isysroot',
          (await iosSdk(targetIosSdk!, logger: logger)).toFilePath(),
        ],
        if (linkConfig.targetOS == OS.macOS) ...[
          '-isysroot',
          (await macosSdk(logger: logger)).toFilePath(),
        ],
        if (installName != null) ...[
          '-install_name',
          installName!.toFilePath(),
        ],
        if (pic != null)
          if (pic!) ...[
            if (dynamicLibrary != null) '-fPIC',
            // Using PIC for static libraries allows them to be linked into
            // any executable, but it is not necessarily the best option in
            // terms of overhead. We would have to know wether the target into
            // which the static library is linked is PIC, PIE or neither. Then
            // we could use the same option for the static library.
            if (staticLibrary != null) '-fPIC',
            if (executable != null) ...[
              // Generate position-independent code for executables.
              '-fPIE',
              // Tell the linker to generate a position-independent executable.
              '-pie',
            ],
          ] else ...[
            // Disable generation of any kind of position-independent code.
            '-fno-PIC',
            '-fno-PIE',
            // Tell the linker to generate a position-dependent executable.
            if (executable != null) '-no-pie',
          ],
        if (std != null) '-std=$std',
        if (language == Language.cpp) ...[
          '-x',
          'c++',
          '-l',
          cppLinkStdLib ?? defaultCppLinkStdLib[linkConfig.targetOS]!
        ],
        ...linkerOptions.preflags(compiler.tool),
        ...flags,
        for (final MapEntry(key: name, :value) in defines.entries)
          if (value == null) '-D$name' else '-D$name=$value',
        for (final include in includes) '-I${include.toFilePath()}',
        ...sourceFiles,
        if (language == Language.objectiveC) ...[
          for (final framework in frameworks) ...[
            '-framework',
            framework,
          ],
        ],
        if (dynamicLibrary != null) ...[
          '--shared',
          '-o',
          outFile!.toFilePath(),
        ] else if (staticLibrary != null) ...[
          '-c',
          '-o',
          outFile!.toFilePath(),
        ],
        ...linkerOptions.flags(compiler.tool),
      ],
      logger: logger,
      captureOutput: false,
      throwOnUnexpectedExitCode: true,
    );
  }

  Future<void> runCl({required ToolInstance compiler}) async {
    final vcvars = (await _resolver.toolchainEnvironmentScript(compiler))!;
    final vcvarsArgs = _resolver.toolchainEnvironmentScriptArguments();
    final environment =
        await environmentFromBatchFile(vcvars, arguments: vcvarsArgs ?? []);

    final isStaticLib = staticLibrary != null;
    Uri? archiver_;
    if (isStaticLib) {
      archiver_ = await archiver();
    }

    final result = await runProcess(
      executable: compiler.uri,
      arguments: [
        if (std != null) '/std:$std',
        if (language == Language.cpp) '/TP',
        ...flags,
        for (final MapEntry(key: name, :value) in defines.entries)
          if (value == null) '/D$name' else '/D$name=$value',
        for (final directory in includes) '/I${directory.toFilePath()}',
        if (executable != null) ...[
          ...sources.map((e) => e.toFilePath()),
          '/link',
          '/out:${outDir.resolveUri(executable!).toFilePath()}',
        ],
        if (dynamicLibrary != null) ...[
          ...sources.map((e) => e.toFilePath()),
          '/link',
          '/DLL',
          '/out:${outDir.resolveUri(dynamicLibrary!).toFilePath()}',
        ],
        if (staticLibrary != null) ...[
          '/c',
          ...sources.map((e) => e.toFilePath()),
        ],
      ],
      workingDirectory: outDir,
      environment: environment,
      logger: logger,
      captureOutput: false,
      throwOnUnexpectedExitCode: true,
    );

    if (staticLibrary != null) {
      await runProcess(
        executable: archiver_!,
        arguments: [
          '/out:${staticLibrary!.toFilePath()}',
          '*.obj',
        ],
        workingDirectory: outDir,
        environment: environment,
        logger: logger,
        captureOutput: false,
        throwOnUnexpectedExitCode: true,
      );
    }

    assert(result.exitCode == 0);
  }

  static const androidNdkClangTargetFlags = {
    Architecture.arm: 'armv7a-linux-androideabi',
    Architecture.arm64: 'aarch64-linux-android',
    Architecture.ia32: 'i686-linux-android',
    Architecture.x64: 'x86_64-linux-android',
    Architecture.riscv64: 'riscv64-linux-android',
  };

  static const appleClangMacosTargetFlags = {
    Architecture.arm64: 'arm64-apple-darwin',
    Architecture.x64: 'x86_64-apple-darwin',
  };

  static const appleClangIosTargetFlags = {
    Architecture.arm64: {
      IOSSdk.iPhoneOS: 'arm64-apple-ios',
      IOSSdk.iPhoneSimulator: 'arm64-apple-ios-simulator',
    },
    Architecture.x64: {
      IOSSdk.iPhoneSimulator: 'x86_64-apple-ios-simulator',
    },
  };

  static const defaultCppLinkStdLib = {
    OS.android: 'c++_shared',
    OS.fuchsia: 'c++',
    OS.iOS: 'c++',
    OS.linux: 'stdc++',
    OS.macOS: 'c++',
  };
}

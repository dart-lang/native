// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import '../native_toolchain/apple_clang.dart';
import '../native_toolchain/clang.dart';
import '../native_toolchain/gcc.dart';
import '../native_toolchain/msvc.dart';
import '../native_toolchain/xcode.dart';
import '../tool/tool_instance.dart';
import '../utils/env_from_bat.dart';
import '../utils/run_process.dart';
import 'cbuilder.dart';
import 'compiler_resolver.dart';

class RunCBuilder {
  final BuildConfig buildConfig;
  final Logger? logger;
  final List<Uri> sources;
  final List<Uri> includes;
  final Uri? executable;
  final Uri? dynamicLibrary;
  final Uri? staticLibrary;
  final Uri outDir;
  final Target target;

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

  RunCBuilder({
    required this.buildConfig,
    this.logger,
    this.sources = const [],
    this.includes = const [],
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
  })  : outDir = buildConfig.outDir,
        target = buildConfig.target,
        assert([executable, dynamicLibrary, staticLibrary]
                .whereType<Uri>()
                .length ==
            1) {
    if (target.os == OS.windows && cppLinkStdLib != null) {
      throw ArgumentError.value(
        cppLinkStdLib,
        'cppLinkStdLib',
        'is not supported when targeting Windows',
      );
    }
  }

  late final _resolver =
      CompilerResolver(buildConfig: buildConfig, logger: logger);

  Future<ToolInstance> compiler() async => await _resolver.resolveCompiler();

  Future<Uri> archiver() async => (await _resolver.resolveArchiver()).uri;

  Future<Uri> iosSdk(IOSSdk iosSdk, {required Logger? logger}) async {
    if (iosSdk == IOSSdk.iPhoneOs) {
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

  Future<void> run() async {
    final compiler_ = await compiler();
    final compilerTool = compiler_.tool;
    if (compilerTool == appleClang ||
        compilerTool == clang ||
        compilerTool == gcc) {
      await runClangLike(compiler: compiler_.uri);
      return;
    }
    assert(compilerTool == cl);
    await runCl(compiler: compiler_);
  }

  Future<void> runClangLike({required Uri compiler}) async {
    final isStaticLib = staticLibrary != null;
    Uri? archiver_;
    if (isStaticLib) {
      archiver_ = await archiver();
    }

    late final IOSSdk targetIosSdk;
    if (target.os == OS.iOS) {
      targetIosSdk = buildConfig.targetIOSSdk!;
    }

    await runProcess(
      executable: compiler,
      arguments: [
        if (target.os == OS.android) ...[
          // TODO(dacoharkes): How to solve linking issues?
          // Non-working fix: --sysroot=$NDKPATH/toolchains/llvm/prebuilt/linux-x86_64/sysroot.
          // The sysroot should be discovered automatically after NDK 22.
          // Workaround:
          if (dynamicLibrary != null) '-nostartfiles',
          '--target='
              '${androidNdkClangTargetFlags[target]!}'
              '${buildConfig.targetAndroidNdkApi!}',
        ],
        if (target.os == OS.macOS)
          '--target=${appleClangMacosTargetFlags[target]!}',
        if (target.os == OS.iOS)
          '--target=${appleClangIosTargetFlags[target]![targetIosSdk]!}',
        if (target.os == OS.iOS) ...[
          '-isysroot',
          (await iosSdk(targetIosSdk, logger: logger)).toFilePath(),
        ],
        if (target.os == OS.macOS) ...[
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
            if (executable != null) '-fPIE',
          ] else ...[
            '-fno-PIC',
            '-fno-PIE',
          ],
        if (std != null) '-std=$std',
        if (language == Language.cpp) ...[
          '-x',
          'c++',
          '-l',
          cppLinkStdLib ?? defaultCppLinkStdLib[target.os]!
        ],
        ...flags,
        for (final MapEntry(key: name, :value) in defines.entries)
          if (value == null) '-D$name' else '-D$name=$value',
        for (final include in includes) '-I${include.toFilePath()}',
        ...sources.map((e) => e.toFilePath()),
        if (executable != null) ...[
          '-o',
          outDir.resolveUri(executable!).toFilePath(),
        ],
        if (dynamicLibrary != null) ...[
          '--shared',
          '-o',
          outDir.resolveUri(dynamicLibrary!).toFilePath(),
        ] else if (staticLibrary != null) ...[
          '-c',
          '-o',
          outDir.resolve('out.o').toFilePath(),
        ],
      ],
      logger: logger,
      captureOutput: false,
      throwOnUnexpectedExitCode: true,
    );
    if (staticLibrary != null) {
      await runProcess(
        executable: archiver_!,
        arguments: [
          'rc',
          outDir.resolveUri(staticLibrary!).toFilePath(),
          outDir.resolve('out.o').toFilePath(),
        ],
        logger: logger,
        captureOutput: false,
        throwOnUnexpectedExitCode: true,
      );
    }
  }

  Future<void> runCl({required ToolInstance compiler}) async {
    final vcvars = (await _resolver.toolchainEnvironmentScript(compiler))!;
    final vcvarsArgs = _resolver.toolchainEnvironmentScriptArguments();
    final environment = await envFromBat(vcvars, arguments: vcvarsArgs ?? []);

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
    Target.androidArm: 'armv7a-linux-androideabi',
    Target.androidArm64: 'aarch64-linux-android',
    Target.androidIA32: 'i686-linux-android',
    Target.androidX64: 'x86_64-linux-android',
  };

  static const appleClangMacosTargetFlags = {
    Target.macOSArm64: 'arm64-apple-darwin',
    Target.macOSX64: 'x86_64-apple-darwin',
  };

  static const appleClangIosTargetFlags = {
    Target.iOSArm64: {
      IOSSdk.iPhoneOs: 'arm64-apple-ios',
      IOSSdk.iPhoneSimulator: 'arm64-apple-ios-simulator',
    },
    Target.iOSX64: {
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

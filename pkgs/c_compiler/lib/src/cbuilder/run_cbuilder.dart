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
import 'compiler_resolver.dart';

class RunCBuilder {
  final BuildConfig buildConfig;
  final Logger? logger;
  final List<Uri> sources;
  final Uri? executable;
  final Uri? dynamicLibrary;
  final Uri? staticLibrary;
  final Uri outDir;
  final Target target;

  /// The install of the [dynamicLibrary].
  ///
  /// Can be inspected with `otool -D <path-to-dylib>`.
  ///
  /// Can be modified with `install_name_tool`.
  final Uri? installName;

  RunCBuilder({
    required this.buildConfig,
    this.logger,
    this.sources = const [],
    this.executable,
    this.dynamicLibrary,
    this.staticLibrary,
    this.installName,
  })  : outDir = buildConfig.outDir,
        target = buildConfig.target,
        assert([executable, dynamicLibrary, staticLibrary]
                .whereType<Uri>()
                .length ==
            1);

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
        if (target.os == OS.macOS || target.os == OS.iOS)
          '--target=${appleClangTargetFlags[target]!}',
        if (target.os == OS.iOS) ...[
          '-isysroot',
          (await iosSdk(buildConfig.targetIOSSdk!, logger: logger))
              .toFilePath(),
        ],
        if (target.os == OS.macOS) ...[
          '-isysroot',
          (await macosSdk(logger: logger)).toFilePath(),
        ],
        if (installName != null) ...[
          '-install_name',
          installName!.toFilePath(),
        ],
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

  static const appleClangTargetFlags = {
    Target.iOSArm64: 'arm64-apple-ios',
    Target.iOSX64: 'x86_64-apple-ios',
    Target.macOSArm64: 'arm64-apple-darwin',
    Target.macOSX64: 'x86_64-apple-darwin',
  };
}

// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import '../../c_compiler.dart';
import '../native_toolchain/msvc.dart';
import '../native_toolchain/xcode.dart';
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

  RunCBuilder({
    required this.buildConfig,
    this.logger,
    this.sources = const [],
    this.executable,
    this.dynamicLibrary,
    this.staticLibrary,
  })  : outDir = buildConfig.outDir,
        target = buildConfig.target,
        assert([executable, dynamicLibrary, staticLibrary]
                .whereType<Uri>()
                .length ==
            1);

  Future<ToolInstance> compiler() async {
    final resolver = CompilerResolver(buildConfig: buildConfig, logger: logger);
    return await resolver.resolveCompiler();
  }

  Future<Uri> archiver() async {
    final resolver = CompilerResolver(buildConfig: buildConfig, logger: logger);
    return (await resolver.resolveArchiver()).uri;
  }

  Future<Uri> iosSdk(IOSSdk iosSdk, {Logger? logger}) async {
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

  Future<Uri> macosSdk({Logger? logger}) async =>
      (await macosxSdk.defaultResolver!.resolve(logger: logger))
          .where((i) => i.tool == macosxSdk)
          .first
          .uri;

  Future<void> run() async {
    final compiler_ = await compiler();
    final compilerTool = compiler_.tool;
    if (compilerTool == clang || compilerTool == gcc) {
      await runClangLike(compiler: compiler_.uri);
      return;
    }
    assert(compilerTool == cl);
    final vcvars =
        (await vcvars64.defaultResolver!.resolve(logger: logger)).first;
    await runCl(
      compiler: compiler_.uri,
      vcvars: vcvars.uri,
    );
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
          '--target=${androidNdkClangTargetFlags[target]!}',
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
      );
    }
  }

  Future<void> runCl({
    required Uri compiler,
    required Uri vcvars,
  }) async {
    final environment = await envFromBat(vcvars);
    final result = await runProcess(
      executable: compiler,
      arguments: [
        ...sources.map((e) => e.toFilePath()),
        if (executable != null) ...[
          '/link',
          '/out:${outDir.resolveUri(executable!).toFilePath()}',
        ],
        if (dynamicLibrary != null) ...[
          '/link',
          '/DLL',
          '/out:${outDir.resolveUri(dynamicLibrary!).toFilePath()}',
        ],
      ],
      workingDirectory: outDir,
      environment: environment,
      logger: logger,
      captureOutput: false,
    );
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
    Target.macOSArm64: 'arm64-apple-darwin',
    Target.macOSX64: 'x86_64-apple-darwin',
  };
}

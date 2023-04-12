// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import '../utils/run_process.dart';
import 'compiler_resolver.dart';

class RunCBuilder {
  final BuildConfig buildConfig;
  final Logger logger;
  final List<Uri> sources;
  final List<Uri> includePaths;
  final Uri? executable;
  final Uri? dynamicLibrary;
  final Uri? staticLibrary;
  final Uri outDir;
  final Target target;

  RunCBuilder({
    required this.buildConfig,
    required this.logger,
    this.sources = const [],
    this.includePaths = const [],
    this.executable,
    this.dynamicLibrary,
    this.staticLibrary,
  })  : outDir = buildConfig.outDir,
        target = buildConfig.target {
    if ([executable, dynamicLibrary, staticLibrary].whereType<Uri>().length !=
        1) {
      throw ArgumentError(
          'Provide one of executable, dynamicLibrary, or staticLibrary.');
    }
  }

  Uri? _compilerCached;

  Future<Uri> compiler() async {
    if (_compilerCached != null) {
      return _compilerCached!;
    }
    final resolver = CompilerResolver(buildConfig: buildConfig, logger: logger);
    _compilerCached = (await resolver.resolve()).first.uri;
    return _compilerCached!;
  }

  Uri? _archiverCached;

  Future<Uri> archiver() async {
    if (_archiverCached != null) {
      return _archiverCached!;
    }
    final compiler_ = await compiler();
    final resolver = CompilerResolver(buildConfig: buildConfig, logger: logger);
    _linkerCached = await resolver.resolveArchiver(
      compiler_,
    );
    return _linkerCached!;
  }

  Uri? _linkerCached;

  Future<Uri> linker() async {
    if (_linkerCached != null) {
      return _linkerCached!;
    }
    final compiler_ = await compiler();
    final resolver = CompilerResolver(buildConfig: buildConfig, logger: logger);
    _linkerCached = await resolver.resolveLinker(
      compiler_,
    );
    return _linkerCached!;
  }

  Future<void> run() async {
    final compiler_ = await compiler();
    final isStaticLib = staticLibrary != null;
    Uri? archiver_;
    if (isStaticLib) {
      archiver_ = await archiver();
    }

    await RunProcess(
      executable: compiler_.path,
      arguments: [
        if (target.os == OS.android) ...[
          // TODO(dacoharkes): How to solve linking issues?
          // Non-working fix: --sysroot=$NDKPATH/toolchains/llvm/prebuilt/linux-x86_64/sysroot.
          // The sysroot should be discovered automatically after NDK 22.
          // Workaround:
          if (dynamicLibrary != null) '-nostartfiles',
          '--target=${androidNdkClangTargetFlags[target]!}',
        ],
        ...sources.map((e) => e.path),
        if (executable != null) ...[
          '-o',
          outDir.resolveUri(executable!).path,
        ],
        if (dynamicLibrary != null) ...[
          '--shared',
          '-o',
          outDir.resolveUri(dynamicLibrary!).path,
        ] else if (staticLibrary != null) ...[
          '-c',
          '-o',
          outDir.resolve('out.o').path,
        ],
      ],
    ).run(logger: logger);
    if (staticLibrary != null) {
      await RunProcess(
        executable: archiver_!.path,
        arguments: [
          'rc',
          outDir.resolveUri(staticLibrary!).path,
          outDir.resolve('out.o').path,
        ],
      ).run(logger: logger);
    }
  }

  static const androidNdkClangTargetFlags = {
    Target.androidArm: 'armv7a-linux-androideabi',
    Target.androidArm64: 'aarch64-linux-android',
    Target.androidIA32: 'i686-linux-android',
    Target.androidX64: 'x86_64-linux-android',
  };
}

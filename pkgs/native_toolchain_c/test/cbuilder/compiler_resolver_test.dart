// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({
  'mac-os': Timeout.factor(2),
  'windows': Timeout.factor(10),
})
library;

import 'package:collection/collection.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/src/cbuilder/compiler_resolver.dart';
import 'package:native_toolchain_c/src/native_toolchain/apple_clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/msvc.dart';
import 'package:native_toolchain_c/src/tool/tool_error.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  test('Config provided compiler', () async {
    final tempUri = await tempDirForTest();
    final ar = [
      ...await appleAr.defaultResolver!.resolve(logger: logger),
      ...await lib.defaultResolver!.resolve(logger: logger),
      ...await llvmAr.defaultResolver!.resolve(logger: logger),
    ].first.uri;
    final cc = [
      ...await appleClang.defaultResolver!.resolve(logger: logger),
      ...await cl.defaultResolver!.resolve(logger: logger),
      ...await clang.defaultResolver!.resolve(logger: logger),
    ].first.uri;
    final ld = [
      ...await appleLd.defaultResolver!.resolve(logger: logger),
      ...await link.defaultResolver!.resolve(logger: logger),
      ...await lld.defaultResolver!.resolve(logger: logger),
    ].first.uri;
    final envScript = [
      ...await vcvars64.defaultResolver!.resolve(logger: logger)
    ].firstOrNull?.uri;
    final buildConfig = BuildConfig.build(
      outputDirectory: tempUri,
      packageName: 'dummy',
      packageRoot: tempUri,
      targetArchitecture: Architecture.current,
      targetOS: OS.current,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      cCompiler: CCompilerConfig(
        archiver: ar,
        compiler: cc,
        linker: ld,
        envScript: envScript,
      ),
    );
    final resolver = CompilerResolver(buildConfig: buildConfig, logger: logger);
    final compiler = await resolver.resolveCompiler();
    final archiver = await resolver.resolveArchiver();
    expect(compiler.uri, buildConfig.cCompiler.compiler);
    expect(archiver.uri, buildConfig.cCompiler.archiver);
  });

  test('No compiler found', () async {
    final tempUri = await tempDirForTest();
    final buildConfig = BuildConfig.build(
      outputDirectory: tempUri,
      packageName: 'dummy',
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.windows,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
    );
    final resolver = CompilerResolver(
      buildConfig: buildConfig,
      logger: logger,
      hostOS: OS.android, // This is never a host.
      hostArchitecture: Architecture.arm64, // This is never a host.
    );
    expect(resolver.resolveCompiler, throwsA(isA<ToolError>()));
    expect(resolver.resolveArchiver, throwsA(isA<ToolError>()));
  });
}

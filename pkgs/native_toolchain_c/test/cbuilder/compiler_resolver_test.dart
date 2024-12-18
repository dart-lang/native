// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({
  'mac-os': Timeout.factor(2),
  'windows': Timeout.factor(10),
})
library;

import 'package:collection/collection.dart';
import 'package:native_toolchain_c/src/cbuilder/compiler_resolver.dart';
import 'package:native_toolchain_c/src/native_toolchain/apple_clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/msvc.dart' as msvc;
import 'package:native_toolchain_c/src/tool/tool_error.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  test('Config provided compiler', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    final ar = [
      ...await appleAr.defaultResolver!.resolve(logger: logger),
      ...await msvc.lib.defaultResolver!.resolve(logger: logger),
      ...await llvmAr.defaultResolver!.resolve(logger: logger),
    ].first.uri;
    final cc = [
      ...await appleClang.defaultResolver!.resolve(logger: logger),
      ...await msvc.cl.defaultResolver!.resolve(logger: logger),
      ...await clang.defaultResolver!.resolve(logger: logger),
    ].first.uri;
    final ld = [
      ...await appleLd.defaultResolver!.resolve(logger: logger),
      ...await msvc.msvcLink.defaultResolver!.resolve(logger: logger),
      ...await lld.defaultResolver!.resolve(logger: logger),
    ].first.uri;
    final envScript = [
      ...await msvc.vcvars64.defaultResolver!.resolve(logger: logger)
    ].firstOrNull?.uri;

    final buildConfigBuilder = BuildConfigBuilder()
      ..setupHookConfig(
        buildAssetTypes: [CodeAsset.type],
        packageName: 'dummy',
        packageRoot: tempUri,
      )
      ..setupBuildConfig(
        linkingEnabled: false,
        dryRun: false,
      )
      ..setupCodeConfig(
        targetOS: OS.current,
        targetArchitecture: Architecture.current,
        linkModePreference: LinkModePreference.dynamic,
        cCompilerConfig: CCompilerConfig(
          archiver: ar,
          compiler: cc,
          linker: ld,
          envScript: envScript,
        ),
      );
    buildConfigBuilder.setupBuildRunConfig(
      outputDirectory: tempUri,
      outputDirectoryShared: tempUri2,
    );
    final buildConfig = BuildConfig(buildConfigBuilder.json);
    final resolver =
        CompilerResolver(codeConfig: buildConfig.codeConfig, logger: logger);
    final compiler = await resolver.resolveCompiler();
    final archiver = await resolver.resolveArchiver();
    expect(compiler.uri, buildConfig.codeConfig.cCompiler?.compiler);
    expect(archiver.uri, buildConfig.codeConfig.cCompiler?.archiver);
  });

  test('No compiler found', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    final buildConfigBuilder = BuildConfigBuilder()
      ..setupHookConfig(
        buildAssetTypes: [CodeAsset.type],
        packageName: 'dummy',
        packageRoot: tempUri,
      )
      ..setupBuildConfig(
        linkingEnabled: false,
        dryRun: false,
      )
      ..setupCodeConfig(
        targetOS: OS.windows,
        targetArchitecture: Architecture.arm64,
        linkModePreference: LinkModePreference.dynamic,
        cCompilerConfig: cCompiler,
      );
    buildConfigBuilder.setupBuildRunConfig(
      outputDirectoryShared: tempUri2,
      outputDirectory: tempUri,
    );

    final buildConfig = BuildConfig(buildConfigBuilder.json);

    final resolver = CompilerResolver(
      codeConfig: buildConfig.codeConfig,
      logger: logger,
      hostOS: OS.android, // This is never a host.
      hostArchitecture: Architecture.arm64, // This is never a host.
    );
    expect(resolver.resolveCompiler, throwsA(isA<ToolError>()));
    expect(resolver.resolveArchiver, throwsA(isA<ToolError>()));
  });
}

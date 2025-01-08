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
  test('Input provided compiler', () async {
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

    final targetOS = OS.current;
    final buildInputBuilder = BuildInputBuilder()
      ..setupHook(
        packageName: 'dummy',
        packageRoot: tempUri,
        outputDirectory: tempUri,
        outputDirectoryShared: tempUri2,
      )
      ..config.setupBuild(
        linkingEnabled: false,
        dryRun: false,
      )
      ..config.setup(buildAssetTypes: [CodeAsset.type])
      ..config.setupCode(
        targetOS: targetOS,
        macOS: targetOS == OS.macOS
            ? MacOSConfig(targetVersion: defaultMacOSVersion)
            : null,
        targetArchitecture: Architecture.current,
        linkModePreference: LinkModePreference.dynamic,
        cCompilerConfig: CCompilerConfig(
          archiver: ar,
          compiler: cc,
          linker: ld,
          envScript: envScript,
        ),
      );
    final buildInput = BuildInput(buildInputBuilder.json);
    final resolver =
        CompilerResolver(codeCondig: buildInput.config.code, logger: logger);
    final compiler = await resolver.resolveCompiler();
    final archiver = await resolver.resolveArchiver();
    expect(compiler.uri, buildInput.config.code.cCompiler?.compiler);
    expect(archiver.uri, buildInput.config.code.cCompiler?.archiver);
  });

  test('No compiler found', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    final buildInputBuilder = BuildInputBuilder()
      ..setupHook(
        packageName: 'dummy',
        packageRoot: tempUri,
        outputDirectoryShared: tempUri2,
        outputDirectory: tempUri,
      )
      ..config.setupBuild(
        linkingEnabled: false,
        dryRun: false,
      )
      ..config.setup(buildAssetTypes: [CodeAsset.type])
      ..config.setupCode(
        targetOS: OS.windows,
        targetArchitecture: Architecture.arm64,
        linkModePreference: LinkModePreference.dynamic,
        cCompilerConfig: cCompiler,
      );

    final buildInput = BuildInput(buildInputBuilder.json);

    final resolver = CompilerResolver(
      codeCondig: buildInput.config.code,
      logger: logger,
      hostOS: OS.android, // This is never a host.
      hostArchitecture: Architecture.arm64, // This is never a host.
    );
    expect(resolver.resolveCompiler, throwsA(isA<ToolError>()));
    expect(resolver.resolveArchiver, throwsA(isA<ToolError>()));
  });
}

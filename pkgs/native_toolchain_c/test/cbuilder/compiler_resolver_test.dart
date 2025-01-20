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
      ..setupShared(
        packageName: 'dummy',
        packageRoot: tempUri,
        outputFile: tempUri.resolve('output.json'),
        outputDirectory: tempUri,
        outputDirectoryShared: tempUri2,
      )
      ..config.setupBuild(
        linkingEnabled: false,
        dryRun: false,
      )
      ..config.setupShared(buildAssetTypes: [CodeAsset.type])
      ..config.setupCode(
        targetOS: targetOS,
        macOS: targetOS == OS.macOS
            ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
            : null,
        targetArchitecture: Architecture.current,
        linkModePreference: LinkModePreference.dynamic,
        cCompiler: CCompilerConfig(
          archiver: ar,
          compiler: cc,
          linker: ld,
          windows: targetOS == OS.windows
              ? WindowsCCompilerConfig(
                  developerCommandPrompt: DeveloperCommandPrompt(
                    script: envScript!,
                    arguments: [],
                  ),
                )
              : null,
        ),
      );
    final buildInput = BuildInput(buildInputBuilder.json);
    final resolver =
        CompilerResolver(codeConfig: buildInput.config.code, logger: logger);
    final compiler = await resolver.resolveCompiler();
    final archiver = await resolver.resolveArchiver();
    expect(compiler.uri, buildInput.config.code.cCompiler?.compiler);
    expect(archiver.uri, buildInput.config.code.cCompiler?.archiver);
    final environment = await resolver.resolveEnvironment(compiler);
    if (targetOS == OS.windows) {
      expect(environment, isNot(equals({})));
    } else {
      expect(environment, equals({}));
    }
  });

  test('No compiler found', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    final buildInputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: 'dummy',
        packageRoot: tempUri,
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: tempUri2,
        outputDirectory: tempUri,
      )
      ..config.setupBuild(
        linkingEnabled: false,
        dryRun: false,
      )
      ..config.setupShared(buildAssetTypes: [CodeAsset.type])
      ..config.setupCode(
        targetOS: OS.windows,
        targetArchitecture: Architecture.arm64,
        linkModePreference: LinkModePreference.dynamic,
        cCompiler: cCompiler,
      );

    final buildInput = BuildInput(buildInputBuilder.json);

    final resolver = CompilerResolver(
      codeConfig: buildInput.config.code,
      logger: logger,
      hostOS: OS.android, // This is never a host.
      hostArchitecture: Architecture.arm64, // This is never a host.
    );
    expect(resolver.resolveCompiler, throwsA(isA<ToolError>()));
    expect(resolver.resolveArchiver, throwsA(isA<ToolError>()));
  });
}
